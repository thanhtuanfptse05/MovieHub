package com.moviehub.controller.admin;

import com.moviehub.dto.AdminCategoryInput;
import com.moviehub.dto.AdminCategoryItem;
import com.moviehub.service.AdminCategoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

public class AdminCategoryServlet extends AdminServletSupport {
    private final AdminCategoryService categories=new AdminCategoryService();
    @Override protected void handle(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
        req.setAttribute("adminSection","categories"); String path=req.getPathInfo(); if(path==null||path.equals("/"))path="";
        if(path.isEmpty()) {
            if(!get(req)){methodError(req,res,"GET");return;}
            listing(req,res);return;
        }
        if(path.equals("/edit")) {
            if(!get(req)){methodError(req,res,"GET");return;}
            AdminCategoryItem item=categories.getCategory(id(req));req.setAttribute("category",item);req.setAttribute("editing",true);
            Map<String,Object> form=new LinkedHashMap<>();form.put("id",item.getId());form.put("version",item.getVersion());form.put("name",item.getName());form.put("slug",item.getSlug());req.setAttribute("form",form);view(req,res,"category-form");return;
        }
        if(!path.equals("/save")&&!path.equals("/delete")){error(req,res,404,"Không tìm thấy trang này.");return;}
        if(get(req)){methodError(req,res,"POST");return;}
        if(path.equals("/delete")) categories.deleteCategory(actor(req),id(req),version(req));
        else {
            boolean editing=!value(req,"id").isEmpty();req.setAttribute("editing",editing);form(req,"id","version","name","slug");
            AdminCategoryInput input=new AdminCategoryInput();input.setName(value(req,"name"));input.setSlug(value(req,"slug"));categories.saveCategory(actor(req),editing?id(req):null,editing?version(req):null,input);
        }
        redirect(req,res,listReturn(req,"/admin/categories","q","page"),path.equals("/delete")?"Đã xóa thể loại.":"Đã lưu thể loại.");
    }
    private void listing(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
        String q=get(req)?value(req,"q"):value(req,"returnQ");String page=get(req)?value(req,"page"):value(req,"returnPage");
        if(!get(req) && q.codePointCount(0,q.length())>200)q="";
        req.setAttribute("q",q);req.setAttribute("pageResult",categories.listCategories(categories.parseQuery(q,page)));view(req,res,"category-manage");
    }
    @Override protected void invalid(HttpServletRequest req,HttpServletResponse res,String message)throws ServletException,IOException {
        if(req.getAttribute("form")==null){super.invalid(req,res,message);return;}
        res.setStatus(400);req.setAttribute("errorMessage",message);
        if(Boolean.TRUE.equals(req.getAttribute("editing")))view(req,res,"category-form");else listing(req,res);
    }
}
