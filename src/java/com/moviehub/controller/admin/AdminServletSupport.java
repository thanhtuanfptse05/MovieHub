package com.moviehub.controller.admin;

import com.moviehub.exception.AdminValidationException;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Logger;

/** Common HTTP presentation only; persistence and policy remain in services. */
public abstract class AdminServletSupport extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(AdminServletSupport.class.getName());
    @Override protected final void service(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setCharacterEncoding("UTF-8"); res.setContentType("text/html; charset=UTF-8");
        res.setHeader("Cache-Control", "no-store");
        if (!"GET".equals(req.getMethod()) && !"POST".equals(req.getMethod())) {
            res.setHeader("Allow", "GET, POST"); error(req,res,405,"Phương thức không được hỗ trợ."); return;
        }
        try { handle(req,res); }
        catch (AdminValidationException ex) { req.setAttribute("fieldErrors", ex.getErrors()); invalid(req,res,ex.getMessage()); }
        catch (IllegalArgumentException ex) { invalid(req,res,ex.getMessage()); }
        catch (NotFoundException ex) { error(req,res,404,ex.getMessage()); }
        catch (ForbiddenException ex) { error(req,res,403,ex.getMessage()); }
        catch (ConflictException ex) { error(req,res,409,ex.getMessage()); }
        catch (RuntimeException ex) {
            String code=UUID.randomUUID().toString().substring(0,8);
            LOG.severe("Admin request failed reference="+code+" exception="+ex.getClass().getSimpleName());
            req.setAttribute("correlationId",code); res.setStatus(500);
            req.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(req,res);
        }
    }
    protected abstract void handle(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException;
    protected void invalid(HttpServletRequest req,HttpServletResponse res,String message) throws ServletException,IOException { error(req,res,400,message); }
    protected void error(HttpServletRequest req,HttpServletResponse res,int status,String message) throws ServletException,IOException {
        res.setStatus(status); req.setAttribute("statusCode",status); req.setAttribute("errorMessage",message);
        String module=req.getServletPath();
        String reload = "/admin/movies".equals(module) || "/admin/categories".equals(module)
                || "/admin/users".equals(module) || "/admin/moderation".equals(module) ? module : "/admin/dashboard";
        req.setAttribute("reloadUrl", req.getContextPath()+reload);
        view(req,res,"error");
    }
    protected void view(HttpServletRequest req,HttpServletResponse res,String name) throws ServletException,IOException {
        for (String key : new String[]{"q","status","role","type","page"}) {
            String cap=Character.toUpperCase(key.charAt(0))+key.substring(1);
            String filter=get(req)?value(req,key):value(req,"return"+cap);
            if(req.getAttribute(key)==null)req.setAttribute(key,filter);
            req.setAttribute("return"+cap,filter);
        }
        if("GET".equals(req.getMethod())) {
            Object flash=req.getSession().getAttribute("adminFlash"); req.getSession().removeAttribute("adminFlash"); req.setAttribute("flashSuccess",flash);
        }
        req.getRequestDispatcher("/WEB-INF/views/admin/"+name+".jsp").forward(req,res);
    }
    protected void redirect(HttpServletRequest req,HttpServletResponse res,String url,String message) {
        if(message!=null) req.getSession().setAttribute("adminFlash",message);
        res.setStatus(303); res.setHeader("Location",req.getContextPath()+url);
    }
    protected static Long actor(HttpServletRequest req) { return (Long)req.getSession(false).getAttribute("userId"); }
    protected static String value(HttpServletRequest req,String key) { String v=req.getParameter(key); return v==null?"":v; }
    protected static Long id(HttpServletRequest req) {
        try { long n=Long.parseLong(value(req,"id")); if(n>0)return n; } catch(NumberFormatException ignored) { }
        throw new NotFoundException("Không tìm thấy nội dung này.");
    }
    protected static Integer version(HttpServletRequest req) { return positive(req,"version",true); }
    protected static Integer positive(HttpServletRequest req,String key,boolean zeroAllowed) {
        try { int n=Integer.parseInt(value(req,key)); if(n>(zeroAllowed?-1:0))return n; } catch(NumberFormatException ignored) { }
        throw new IllegalArgumentException("Thông tin gửi lên không hợp lệ. Vui lòng tải lại trang.");
    }
    protected static int page(HttpServletRequest req) {
        try { return Math.max(1,Integer.parseInt(value(req,"page"))); } catch(NumberFormatException ignored) { return 1; }
    }
    protected static Map<String,Object> form(HttpServletRequest req,String... fields) {
        Map<String,Object> form=new LinkedHashMap<>(); for(String field:fields)form.put(field,value(req,field)); req.setAttribute("form",form); return form;
    }
    protected static String listReturn(HttpServletRequest req,String path,String... keys) {
        StringBuilder url=new StringBuilder(path); char sep='?';
        for(String key:keys) {
            String cap=Character.toUpperCase(key.charAt(0))+key.substring(1);
            String v=value(req,"return"+cap);
            if(!v.isEmpty()) { url.append(sep).append(key).append('=').append(URLEncoder.encode(v,StandardCharsets.UTF_8)); sep='&'; }
        }
        return url.toString();
    }
    protected static boolean get(HttpServletRequest req) { return "GET".equals(req.getMethod()); }
    protected void methodError(HttpServletRequest req,HttpServletResponse res,String allowed) throws ServletException,IOException { res.setHeader("Allow",allowed); error(req,res,405,"Phương thức không được hỗ trợ."); }
}
