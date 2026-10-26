package com.moviehub.controller.admin;

import com.moviehub.service.AdminModerationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminModerationServlet extends AdminServletSupport {
    private final AdminModerationService moderation=new AdminModerationService();
    @Override protected void handle(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
        req.setAttribute("adminSection","moderation");String path=req.getPathInfo();if(path==null||path.equals("/"))path="";
        if(path.isEmpty()) {
            if(!get(req)){methodError(req,res,"GET");return;}
            String type=value(req,"type"),status=value(req,"status");if(type.isEmpty())type="all";if(status.isEmpty())status="PENDING";
            req.setAttribute("type",type);req.setAttribute("status",status);req.setAttribute("pageResult",moderation.list(type,status,page(req)));view(req,res,"moderation");return;
        }
        if(!path.equals("/decide")){error(req,res,404,"Không tìm thấy trang này.");return;}
        if(get(req)){methodError(req,res,"POST");return;}
        moderation.decide(actor(req),value(req,"type"),id(req),value(req,"action"),version(req),positive(req,"contentRevision",false));
        redirect(req,res,listReturn(req,"/admin/moderation","type","status","page"),"Đã cập nhật trạng thái nội dung.");
    }
}
