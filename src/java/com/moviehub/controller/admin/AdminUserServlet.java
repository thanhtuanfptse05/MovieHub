package com.moviehub.controller.admin;

import com.moviehub.dto.AdminUserItem;
import com.moviehub.service.AdminUserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

public class AdminUserServlet extends AdminServletSupport {
    private final AdminUserService users=new AdminUserService();
    @Override protected void handle(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
        req.setAttribute("adminSection","users");String path=req.getPathInfo();if(path==null||path.equals("/"))path="";
        if(path.isEmpty()) {
            if(!get(req)){methodError(req,res,"GET");return;}
            req.setAttribute("pageResult",users.list(value(req,"q"),value(req,"role"),value(req,"status"),page(req)));view(req,res,"user-manage");return;
        }
        if(path.equals("/edit")) {
            if(!get(req)){methodError(req,res,"GET");return;}
            AdminUserItem u=users.get(id(req));req.setAttribute("user",u);
            Map<String,Object> form=new LinkedHashMap<>();form.put("id",u.getId());form.put("version",u.getVersion());form.put("role",u.getRole());form.put("status",u.getStatus());req.setAttribute("form",form);view(req,res,"user-form");return;
        }
        if(!path.equals("/update")){error(req,res,404,"Không tìm thấy trang này.");return;}
        if(get(req)){methodError(req,res,"POST");return;}
        form(req,"id","version","role","status"); req.setAttribute("user",users.get(id(req)));
        users.update(actor(req),id(req),version(req),value(req,"role"),value(req,"status"));redirect(req,res,listReturn(req,"/admin/users","q","role","status","page"),"Đã cập nhật tài khoản.");
    }
    @Override protected void invalid(HttpServletRequest req,HttpServletResponse res,String message)throws ServletException,IOException {
        if(req.getAttribute("form")!=null){res.setStatus(400);req.setAttribute("errorMessage",message);view(req,res,"user-form");}else super.invalid(req,res,message);
    }
}
