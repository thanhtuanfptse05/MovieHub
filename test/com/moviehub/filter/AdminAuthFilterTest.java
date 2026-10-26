package com.moviehub.filter;

import com.moviehub.dao.UserDAO;
import com.moviehub.entity.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.junit.Test;
import static org.junit.Assert.*;

public class AdminAuthFilterTest {
    @Test public void guestGets303WithoutAdminData() throws Exception {
        Harness h = new Harness(null); h.run(null);
        assertEquals(303, h.status); assertEquals("/MovieHub/login", h.headers.get("Location")); assertFalse(h.passed);
    }
    @Test public void staleSessionRoleCannotGrantAdmin() throws Exception {
        Harness h = new Harness("ADMIN"); h.run(user("USER", "ACTIVE"));
        assertEquals(403, h.status); assertFalse(h.passed);
    }
    @Test public void promotedRoleIsEffectiveImmediately() throws Exception {
        Harness h = new Harness("USER"); h.run(user("ADMIN", "ACTIVE"));
        assertTrue(h.passed); assertEquals("ADMIN", h.sessionData.get("userRole"));
        assertEquals("no-store", h.headers.get("Cache-Control"));
    }
    @Test public void lockedAdminLosesSession() throws Exception {
        Harness h = new Harness("ADMIN"); h.run(user("ADMIN", "INACTIVE"));
        assertTrue(h.invalidated); assertEquals(303, h.status); assertFalse(h.passed);
    }
    @Test public void revokedCredentialsLoseSession() throws Exception {
        Harness h = new Harness("ADMIN"); User u = user("ADMIN", "ACTIVE"); u.setCredentialsVersion(2); h.run(u);
        assertTrue(h.invalidated); assertEquals(303, h.status); assertFalse(h.passed);
    }
    @Test public void unsupportedVerbIs405BeforeAuthenticationOrCsrf() throws Exception {
        Harness h=new Harness(null); h.method="PUT";h.run(null);assertEquals(405,h.status);assertFalse(h.passed);
    }
    @Test public void postToReadOnlyRouteIs405BeforeAuthenticationOrCsrf() throws Exception {
        Harness h=new Harness(null); h.method="POST";h.run(null);assertEquals(405,h.status);assertFalse(h.passed);
    }
    private static User user(String role, String status) {
        User u = new User(); u.setId(1L); u.setRole(role); u.setStatus(status); u.setCredentialsVersion(1); return u;
    }
    @SuppressWarnings("unchecked") private static <T> T proxy(Class<T> type, java.lang.reflect.InvocationHandler handler) {
        return (T) Proxy.newProxyInstance(type.getClassLoader(), new Class<?>[]{type}, handler);
    }
    private static class Harness {
        final Map<String,Object> sessionData = new HashMap<>(); final Map<String,String> headers = new HashMap<>();
        int status = 200; boolean passed, invalidated; final boolean loggedIn; String method="GET";
        Harness(String role) { loggedIn=role!=null; sessionData.put("userId",1L); sessionData.put("userRole",role); sessionData.put("credentialsVersion",1); }
        void run(User user) throws Exception {
            HttpSession session = proxy(HttpSession.class,(p,m,a)-> {
                switch(m.getName()) { case "getAttribute":return sessionData.get(a[0]); case "setAttribute":sessionData.put((String)a[0],a[1]);return null; case "invalidate":invalidated=true;return null; default:return null; }
            });
            HttpServletRequest req = proxy(HttpServletRequest.class,(p,m,a)-> {
                switch(m.getName()) { case "getSession":return loggedIn?session:null; case "getContextPath":return "/MovieHub"; case "getRequestURI":return "/MovieHub/admin/movies"; case "getMethod":return method; case "getRequestDispatcher":return proxy(RequestDispatcher.class,(x,y,z)->null); default:return null; }
            });
            HttpServletResponse res=proxy(HttpServletResponse.class,(p,m,a)-> {
                if(m.getName().equals("setStatus")) status=(Integer)a[0];
                if(m.getName().equals("setHeader")) headers.put((String)a[0],(String)a[1]); return null;
            });
            AdminAuthFilter filter=new AdminAuthFilter(new UserDAO(){ @Override public Optional<User> findById(Long id){return Optional.ofNullable(user);} });
            FilterChain chain=(r,s)->passed=true; filter.doFilter(req,res,chain);
        }
    }
}
