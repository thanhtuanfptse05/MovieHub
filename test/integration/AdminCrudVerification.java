import com.moviehub.dao.AdminTransactions;
import com.moviehub.dto.*;
import com.moviehub.entity.*;
import com.moviehub.exception.*;
import com.moviehub.service.*;
import com.moviehub.util.JPAUtil;
import com.moviehub.util.PasswordUtil;
import jakarta.persistence.EntityManager;
import java.io.*;
import java.nio.file.*;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.*;
import java.util.function.Function;

/** Opt-in SQL Server verification. Uses generated fixtures; cleanup only soft-hides/revokes them. */
public class AdminCrudVerification {
    static final Path STATE=Path.of("scratch/admin007/fixture.properties");
    static final Properties state=new Properties();
    static final AdminMovieService movies=new AdminMovieService();
    static final AdminCategoryService categories=new AdminCategoryService();
    static final AdminUserService users=new AdminUserService();
    static final AdminModerationService moderation=new AdminModerationService();
    static <T>T tx(Function<EntityManager,T> work) {
        EntityManager em=JPAUtil.getEntityManager();
        try {em.getTransaction().begin();T result=work.apply(em);em.getTransaction().commit();return result;}
        catch(RuntimeException ex){if(em.getTransaction().isActive())em.getTransaction().rollback();throw ex;}
        finally{em.close();}
    }
    static void check(boolean condition,String message){if(!condition)throw new AssertionError(message);System.out.println("PASS "+message);}
    static long id(String key){return Long.parseLong(state.getProperty(key));}
    static void save()throws Exception{Files.createDirectories(STATE.getParent());try(OutputStream out=Files.newOutputStream(STATE)){state.store(out,"Generated verification fixture IDs; no credentials");}}
    static void expect(Class<? extends RuntimeException> type,Runnable work){try{work.run();throw new AssertionError("Expected "+type.getSimpleName());}catch(RuntimeException ex){if(!type.isInstance(ex))throw ex;}}
    static AdminMovieInput input(String title,String slug,String status,Long category) {
        AdminMovieInput in=new AdminMovieInput();in.setTitle(title);in.setSlug(slug);in.setDescription("Nội dung kiểm chứng quản trị: tiếng Việt đầy đủ dấu.");in.setReleaseYear("2026");in.setDurationMinutes("100");in.setStatus(status);
        in.setPosterUrl(state.getProperty("poster"));in.setCategoryIds(category==null?new String[0]:new String[]{category.toString()});return in;
    }
    static long user(EntityManager em,String email,String role,String password) {
        User user=new User("Tài khoản kiểm chứng quản trị",email,PasswordUtil.hashPassword(password),role,"ACTIVE");em.persist(user);em.flush();return user.getId();
    }
    static void seed()throws Exception {
        String password=System.getenv("ADMIN007_TEST_PASSWORD");if(password==null||password.length()<12)throw new IllegalArgumentException("ADMIN007_TEST_PASSWORD required");
        String suffix=UUID.randomUUID().toString().substring(0,8);state.setProperty("suffix",suffix);
        tx(em->{
            state.setProperty("originalAdmin",em.createQuery("select u.id from User u where u.role='ADMIN' and u.status='ACTIVE' order by u.id",Long.class).setMaxResults(1).getSingleResult().toString());
            for(String key:new String[]{"adminA","adminB","regular"}) {
                String email="verify-007-"+key.toLowerCase(Locale.ROOT)+"-"+suffix+"@example.invalid";state.setProperty(key+"Email",email);
                state.setProperty(key,Long.toString(user(em,email,key.equals("regular")?"USER":"ADMIN",password)));
            }
            List<String> posters=em.createQuery("select m.posterUrl from Movie m where m.status='PUBLISHED' and m.posterUrl is not null",String.class).setMaxResults(1).getResultList();
            if(posters.isEmpty())throw new IllegalStateException("A DB poster fixture is required");state.setProperty("poster",posters.get(0));return null;
        });save();
        check(users.list(null,null,null,1).getTotal()>=3,"real user query and safe DTO projection");
        moderation.list(null,null,1);check(true,"real unified queue JPQL");
        AdminCategoryInput cat=new AdminCategoryInput();cat.setName("Kiểm chứng quản trị "+suffix);cat.setSlug("verify-007-"+suffix);
        AdminCategoryItem category=categories.saveCategory(id("adminA"),null,null,cat);state.setProperty("category",category.getId().toString());save();
        AdminMovieItem movie=movies.createMovie(id("adminA"),input("Phim kiểm chứng quản trị "+suffix,"verify-007-"+suffix,"DRAFT",category.getId()));state.setProperty("movie",movie.getId().toString());save();
        check(movie.getViewCount()==0 && movie.getStatus().equals("DRAFT"),"movie create server defaults");
        AdminMovieInput bad=input("Phim kiểm chứng quản trị "+suffix,movie.getSlug(),"PUBLISHED",category.getId());bad.setPosterUrl("");
        expect(AdminValidationException.class,()->movies.updateMovie(id("adminA"),movie.getId(),movie.getVersion(),bad));
        check(movies.getMovie(movie.getId()).getVersion().equals(movie.getVersion()),"invalid publish rolls back movie and links");
        AdminMovieItem published=movies.updateMovie(id("adminA"),movie.getId(),movie.getVersion(),input(movie.getTitle(),movie.getSlug(),"PUBLISHED",category.getId()));
        check(published.getStatus().equals("PUBLISHED"),"publish with DB category and poster");
        expect(ConflictException.class,()->categories.deleteCategory(id("adminA"),category.getId(),category.getVersion()));
        check(true,"linked category deletion blocked");
        tx(em->{
            Review r=new Review(id("regular"),movie.getId(),5,"Đánh giá kiểm chứng: câu chuyện và hình ảnh rõ nét.");em.persist(r);
            Question q=new Question(movie.getId(),id("regular"),"Phim này có nội dung phù hợp để xem cùng gia đình không?");em.persist(q);em.flush();
            Answer a=new Answer(q.getId(),id("regular"),"Bạn có thể tham khảo phần mô tả trước khi xem.");em.persist(a);em.flush();
            state.setProperty("review",r.getId().toString());state.setProperty("question",q.getId().toString());state.setProperty("answer",a.getId().toString());return null;
        });save();verifyModeration();verifyRaces();verifyRollback();unicode();
        check(true,"SQL Server integration complete; fixtures ready for HTTP checks");
    }
    static void verifyModeration() {
        Review before=AdminTransactions.read(em->em.find(Review.class,id("review")));
        check(moderation.decide(id("adminA"),"review",before.getId(),"APPROVE",before.getVersion(),before.getContentRevision()),"review approve committed");
        Review first=AdminTransactions.read(em->em.find(Review.class,before.getId()));
        check(!moderation.decide(id("adminB"),"review",before.getId(),"APPROVE",before.getVersion(),before.getContentRevision()),"same revision retry is no-op");
        Review second=AdminTransactions.read(em->em.find(Review.class,before.getId()));
        check(first.getModeratedBy().equals(second.getModeratedBy())&&first.getModeratedAt().equals(second.getModeratedAt())&&first.getVersion().equals(second.getVersion()),"no-op preserves first audit/version");
        expect(ConflictException.class,()->moderation.decide(id("adminA"),"answer",id("answer"),"APPROVE",1,1));
        Question q=AdminTransactions.read(em->em.find(Question.class,id("question")));
        moderation.decide(id("adminA"),"question",q.getId(),"APPROVE",q.getVersion(),1);
        Answer a=AdminTransactions.read(em->em.find(Answer.class,id("answer")));
        moderation.decide(id("adminA"),"answer",a.getId(),"APPROVE",a.getVersion(),1);
        tx(em->{Review r=em.find(Review.class,before.getId());r.setContent("Tác giả đã sửa: bản nội dung mới cần được đọc lại.");r.setContentRevision(r.getContentRevision()+1);r.setStatus("PENDING");r.setModeratedBy(null);r.setModeratedAt(null);r.setUpdatedAt(Instant.now());return null;});
        expect(ConflictException.class,()->moderation.decide(id("adminA"),"review",before.getId(),"APPROVE",first.getVersion(),first.getContentRevision()));
        check(true,"stale content revision cannot approve revised review");
    }
    static void verifyRaces()throws Exception {
        ExecutorService pool=Executors.newFixedThreadPool(2);
        try {
            CountDownLatch start=new CountDownLatch(1);int va=users.get(id("adminA")).getVersion(),vb=users.get(id("adminB")).getVersion();
            Future<Boolean> one=pool.submit(()->{start.await();try{users.update(id("adminA"),id("adminB"),vb,"USER","ACTIVE");return true;}catch(ForbiddenException|ConflictException ex){return false;}});
            Future<Boolean> two=pool.submit(()->{start.await();try{users.update(id("adminB"),id("adminA"),va,"USER","ACTIVE");return true;}catch(ForbiddenException|ConflictException ex){return false;}});
            start.countDown();check(one.get(30,TimeUnit.SECONDS)^two.get(30,TimeUnit.SECONDS),"concurrent cross-admin revocation permits only one decision");
            for(String key:new String[]{"adminA","adminB"}){AdminUserItem u=users.get(id(key));users.update(id("originalAdmin"),u.getId(),u.getVersion(),"ADMIN","ACTIVE");}
            AdminCategoryInput cat=new AdminCategoryInput();cat.setName("Thể loại kiểm chứng đồng thời "+state.getProperty("suffix"));cat.setSlug("verify-007-race-"+state.getProperty("suffix"));AdminCategoryItem c=categories.saveCategory(id("adminA"),null,null,cat);state.setProperty("raceCategory",c.getId().toString());save();
            CountDownLatch race=new CountDownLatch(1);
            Future<Boolean> assigned=pool.submit(()->{race.await();try{AdminMovieItem m=movies.createMovie(id("adminA"),input("Kiểm chứng gán thể loại",cat.getSlug(),"DRAFT",c.getId()));state.setProperty("raceMovie",m.getId().toString());return true;}catch(AdminValidationException ex){return false;}});
            Future<Boolean> deleted=pool.submit(()->{race.await();try{categories.deleteCategory(id("adminB"),c.getId(),c.getVersion());return true;}catch(ConflictException ex){return false;}});
            race.countDown();check(assigned.get(30,TimeUnit.SECONDS)^deleted.get(30,TimeUnit.SECONDS),"category assignment/delete race cannot both commit");save();
        } finally {pool.shutdownNow();}
    }
    static void verifyRollback() {
        String slug="verify-rollback-"+state.getProperty("suffix");
        expect(IllegalStateException.class,()->AdminTransactions.write(id("adminA"),em->{Category c=new Category();c.setName("Kiểm chứng rollback");c.setNameKey(slug);c.setSlug(slug);c.setCreatedAt(Instant.now());em.persist(c);em.flush();throw new IllegalStateException("forced test rollback");}));
        check(AdminTransactions.read(em->em.createQuery("select count(c) from Category c where c.slug=:slug",Long.class).setParameter("slug",slug).getSingleResult())==0,"transaction failure rolls back inserted category");
    }
    static void unicode() {
        String pattern=".*(?:áº|á»|Ã|Â|Ä|Æ|â€|\uFFFD|\\?\\?).*";
        List<String> texts=AdminTransactions.read(em->{List<String> out=new ArrayList<>();for(Movie m:em.createQuery("select m from Movie m",Movie.class).getResultList()){out.add(m.getTitle());out.add(m.getDescription());}for(Category c:em.createQuery("select c from Category c",Category.class).getResultList())out.add(c.getName());for(User u:em.createQuery("select u from User u",User.class).getResultList())out.add(u.getFullName());return out;});
        for(String text:texts)if(text!=null&&java.util.regex.Pattern.compile(pattern,java.util.regex.Pattern.DOTALL).matcher(text).matches())throw new AssertionError("DB Unicode corruption detected");
        check(true,"DB Vietnamese/Unicode round-trip and corruption scan");
    }
    static void cleanup() {
        for(String key:new String[]{"movie","raceMovie"})if(state.containsKey(key)){AdminMovieItem m=movies.getMovie(id(key));movies.updateMovie(id("originalAdmin"),m.getId(),m.getVersion(),input(m.getTitle(),m.getSlug(),"HIDDEN",null));}
        for(String key:new String[]{"category","raceCategory"})if(state.containsKey(key))try{AdminCategoryItem c=categories.getCategory(id(key));categories.deleteCategory(id("originalAdmin"),c.getId(),c.getVersion());}catch(NotFoundException alreadyDeleted){/* Fixture may have been retired by the race check. */}
        for(String key:new String[]{"adminA","adminB","regular"})if(state.containsKey(key)){AdminUserItem u=users.get(id(key));users.update(id("originalAdmin"),u.getId(),u.getVersion(),"USER","INACTIVE");}
        unicode();check(true,"generated users revoked and generated movies hidden; existing records preserved");
    }
    static void httpcheck()throws Exception {
        long httpMovie=Long.parseLong(Files.readString(Path.of("scratch/admin007/http-movie-id")));
        Movie m=AdminTransactions.read(em->em.find(Movie.class,httpMovie));
        check(httpMovie!=999999 && m.getViewCount()==0 && "HIDDEN".equals(m.getStatus()),"HTTP ignores server-managed id/viewCount and hides instead of deleting");
        String httpSlug=Files.readString(Path.of("scratch/admin007/http-slug"));
        long count=AdminTransactions.read(em->em.createQuery("select count(m) from Movie m where m.slug like :slug",Long.class).setParameter("slug",httpSlug+"%").getSingleResult());
        check(count==1,"HTTP committed submission nonce creates exactly one DB row");
        AdminMovieItem fixture=movies.getMovie(id("movie"));
        String proof="Hành trình qua miền ký ức "+state.getProperty("suffix");
        movies.updateMovie(id("originalAdmin"),fixture.getId(),fixture.getVersion(),input(proof,fixture.getSlug(),fixture.getStatus(),id("category")));
        state.setProperty("proofTitle",proof);save();unicode();check(true,"DB fixture title changed without editing UI source");
    }
    static void credentials()throws Exception {
        AdminUserItem initial=users.get(id("regular"));
        users.update(id("originalAdmin"),initial.getId(),initial.getVersion(),"USER","ACTIVE");
        User current=AdminTransactions.read(em->em.find(User.class,id("regular")));
        CountDownLatch locked=new CountDownLatch(1),release=new CountDownLatch(1);
        com.moviehub.dao.AdminUserDAO dao=new com.moviehub.dao.AdminUserDAO(){
            @Override public User findForUpdate(EntityManager em,Long target){User result=super.findForUpdate(em,target);locked.countDown();try{if(!release.await(10,TimeUnit.SECONDS))throw new IllegalStateException("verification timeout");}catch(InterruptedException ex){Thread.currentThread().interrupt();throw new IllegalStateException(ex);}return result;}
        };
        String password=System.getenv("ADMIN007_TEST_PASSWORD");if(password==null)throw new IllegalArgumentException("ADMIN007_TEST_PASSWORD required");
        String hash=PasswordUtil.hashPassword(password);
        ExecutorService pool=Executors.newFixedThreadPool(2);
        try {
            Future<?> edit=pool.submit(()->new AdminUserService(dao).update(id("originalAdmin"),current.getId(),current.getVersion(),"ADMIN","ACTIVE"));
            if(!locked.await(10,TimeUnit.SECONDS))throw new AssertionError("Target row was not locked");
            Future<Boolean> reset=pool.submit(()->new com.moviehub.dao.UserDAO().updatePasswordAndIncrementCredentials(current.getId(),hash,current.getCredentialsVersion()));
            try{reset.get(300,TimeUnit.MILLISECONDS);throw new AssertionError("Password reset bypassed account edit row lock");}catch(TimeoutException expected){check(true,"password reset waits for account edit row lock");}
            release.countDown();edit.get(10,TimeUnit.SECONDS);check(reset.get(10,TimeUnit.SECONDS),"concurrent password reset commits after role update");
            User after=AdminTransactions.read(em->em.find(User.class,current.getId()));
            check(hash.equals(after.getPasswordHash())&&after.getCredentialsVersion()==current.getCredentialsVersion()+1&&"ADMIN".equals(after.getRole()),"role update preserves concurrently reset credentials");
            users.update(id("originalAdmin"),after.getId(),after.getVersion(),"USER","INACTIVE");unicode();
        } finally {release.countDown();pool.shutdownNow();}
    }
    public static void main(String[] args)throws Exception {
        try {if(args.length==0)throw new IllegalArgumentException("seed|unicode|httpcheck|credentials|cleanup required");if(!args[0].equals("seed"))try(InputStream in=Files.newInputStream(STATE)){state.load(in);}switch(args[0]){case "seed":seed();break;case "unicode":unicode();break;case "httpcheck":httpcheck();break;case "credentials":credentials();break;case "cleanup":cleanup();break;default:throw new IllegalArgumentException("Unknown command");}}
        finally{JPAUtil.shutdown();}
    }
}
