package com.moviehub.controller.admin;

import com.moviehub.dto.AdminMovieInput;
import com.moviehub.dto.AdminMovieItem;
import com.moviehub.service.AdminCategoryService;
import com.moviehub.service.AdminMovieService;
import com.moviehub.util.SubmissionNonceUtil;
import com.moviehub.util.SubmissionNonceUtil.NonceRecord;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

public class AdminMovieServlet extends AdminServletSupport {
    private final AdminMovieService movies=new AdminMovieService();
    private final AdminCategoryService categories=new AdminCategoryService();
    @Override protected void handle(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setAttribute("adminSection","movies");
        String path=req.getPathInfo(); if(path==null||path.equals("/"))path="";
        if(path.isEmpty()) {
            if(!get(req)){methodError(req,res,"GET");return;}
            req.setAttribute("pageResult",movies.listMovies(movies.parseQuery(value(req,"q"),value(req,"status"),value(req,"page")))); view(req,res,"movie-manage"); return;
        }
        if(!Set.of("/create","/edit","/hide").contains(path)){error(req,res,404,"Không tìm thấy trang này.");return;}
        if(path.equals("/hide")) {
            if(get(req)){methodError(req,res,"POST");return;}
            movies.hideMovie(actor(req),id(req),version(req)); redirect(req,res,listReturn(req,"/admin/movies","q","status","page"),"Đã ẩn phim."); return;
        }
        boolean editing=path.equals("/edit"); req.setAttribute("editing",editing);
        if(get(req)) {
            AdminMovieItem m=editing?movies.getMovie(id(req)):null; req.setAttribute("movie",m);
            Map<String,Object> form=new LinkedHashMap<>();
            if(m!=null) {
                form.put("id",m.getId());form.put("version",m.getVersion());form.put("title",m.getTitle());form.put("slug",m.getSlug());form.put("description",m.getDescription());form.put("releaseYear",m.getReleaseYear());form.put("durationMinutes",m.getDurationMinutes());form.put("posterUrl",m.getPosterUrl());form.put("videoUrl",m.getVideoUrl());form.put("trailerUrl",m.getTrailerUrl());form.put("status",m.getStatus());form.put("featured",m.isFeatured());
                req.setAttribute("selectedCategoryIds",new LinkedHashSet<>(m.getCategoryIds()));
            } else { form.put("status","DRAFT");form.put("featured",false); req.setAttribute("selectedCategoryIds",Set.of()); req.setAttribute("submissionId",SubmissionNonceUtil.generateNonce(req.getSession(),actor(req),"MOVIE",0L)); }
            req.setAttribute("form",form); showForm(req,res); return;
        }
        Map<String,Object> form=form(req,"id","version","title","slug","description","releaseYear","durationMinutes","posterUrl","videoUrl","trailerUrl","status");
        String featuredValue=value(req,"featured");
        boolean featured="on".equals(featuredValue)||"true".equals(featuredValue); form.put("featured",featured);
        if(!featuredValue.isEmpty()&&!java.util.Set.of("true","false","on").contains(featuredValue)) {
            throw new com.moviehub.exception.AdminValidationException(Map.of("featured","Lựa chọn phim nổi bật không hợp lệ."));
        }
        String[] categoryIds=req.getParameterValues("categoryIds"); Set<Long> selected=new LinkedHashSet<>(); if(categoryIds!=null)for(String s:categoryIds)try{selected.add(Long.valueOf(s));}catch(NumberFormatException ignored){}
        req.setAttribute("selectedCategoryIds",selected); req.setAttribute("submissionId",value(req,"submissionId"));
        AdminMovieInput input=new AdminMovieInput(); input.setTitle(value(req,"title"));input.setSlug(value(req,"slug"));input.setDescription(value(req,"description"));input.setReleaseYear(value(req,"releaseYear"));input.setDurationMinutes(value(req,"durationMinutes"));input.setPosterUrl(value(req,"posterUrl"));input.setVideoUrl(value(req,"videoUrl"));input.setTrailerUrl(value(req,"trailerUrl"));input.setStatus(!editing&&value(req,"status").isEmpty()?"DRAFT":value(req,"status"));input.setFeatured(featured);input.setCategoryIds(categoryIds);
        if(editing)movies.updateMovie(actor(req),id(req),version(req),input);
        else {
            NonceRecord nonce=SubmissionNonceUtil.validateNonce(req.getSession(),value(req,"submissionId"),actor(req),"MOVIE",0L);
            synchronized(nonce) {
                if(nonce.isCommitted()){redirect(req,res,nonce.getRedirectUrl(),null);return;}
                AdminMovieItem created=movies.createMovie(actor(req),input); String url=listReturn(req,"/admin/movies","q","status","page"); nonce.markCommitted(url,created.getId());
            }
        }
        redirect(req,res,listReturn(req,"/admin/movies","q","status","page"),"Đã lưu phim.");
    }
    private void showForm(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{req.setAttribute("categories",categories.listActiveCategories());view(req,res,"movie-form");}
    @Override protected void invalid(HttpServletRequest req,HttpServletResponse res,String message)throws ServletException,IOException {
        if(req.getAttribute("form")!=null){res.setStatus(400);req.setAttribute("errorMessage",message);showForm(req,res);}else super.invalid(req,res,message);
    }
}
