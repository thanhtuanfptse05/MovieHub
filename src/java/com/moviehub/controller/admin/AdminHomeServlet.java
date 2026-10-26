package com.moviehub.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminHomeServlet extends AdminServletSupport {
    @Override protected void handle(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        if(!get(req)) { methodError(req,res,"GET"); return; }
        req.setAttribute("adminSection","dashboard");
        if("/admin".equals(req.getServletPath()) || "/admin/".equals(req.getServletPath())) redirect(req,res,"/admin/dashboard",null);
        else view(req,res,"dashboard");
    }
}
