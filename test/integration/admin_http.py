"""Opt-in HTTP verification against generated SQL fixtures from AdminCrudVerification."""
import html
import http.cookiejar
import json
import re
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

BASE = "http://localhost:8080/MovieHub"
OUT = Path("scratch/admin007")
FIXTURE = dict(line.split("=", 1) for line in (OUT / "fixture.properties").read_text().splitlines() if line and not line.startswith("#"))
BAD = re.compile(r"áº|á»|Ã|Â|Ä|Æ|â€|\ufffd|\?\?")


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


class Client:
    def __init__(self):
        self.cookies = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cookies), NoRedirect())

    def request(self, path, data=None, method=None):
        body = urllib.parse.urlencode(data, doseq=True).encode("utf-8") if data is not None else None
        req = urllib.request.Request(BASE + path, data=body, method=method)
        try:
            response = self.opener.open(req, timeout=20)
        except urllib.error.HTTPError as error:
            response = error
        text = response.read().decode("utf-8", "strict")
        assert not BAD.search(text), f"Corrupt served Unicode at {path}"
        return response.code, text, response.headers

    def login(self, email):
        _, body, headers = self.request("/login")
        status, _, _ = self.request("/login", {"email": email, "password": (OUT / "password").read_text(), "csrfToken": token(body, headers)})
        assert status in (302, 303), f"Login failed: {status}"


def token(body, headers=None):
    if headers and headers.get("X-CSRF-TOKEN"):
        return headers["X-CSRF-TOKEN"]
    return re.search(r'name="csrfToken"\s+value="([^"]+)"', body).group(1)


def inputs(body):
    return {key: html.unescape(value) for key, value in re.findall(r'<input[^>]*name="([^"]+)"[^>]*value="([^"]*)"', body)}


def check(condition, message):
    assert condition, message
    print("PASS", message)


def main():
    guest = Client()
    for path in ("/admin", "/admin/dashboard", "/admin/movies", "/admin/categories", "/admin/users", "/admin/moderation"):
        check(guest.request(path)[0] == 303, "guest guard " + path)
    check(guest.request("/admin/movies/hide", {"id": FIXTURE["movie"]})[0] == 303, "guest POST guard runs before CSRF")
    regular = Client()
    regular.login(FIXTURE["regularEmail"])
    check(regular.request("/admin/users")[0] == 403, "active USER cannot read admin data")
    check(regular.request("/admin/movies/hide", {"id": FIXTURE["movie"]})[0] == 403, "active USER cannot POST admin mutation")
    admin = Client()
    admin.login(FIXTURE["adminAEmail"])
    (OUT / "browser-cookies.json").write_text(json.dumps([{"name": c.name, "value": c.value, "domain": "localhost", "path": c.path, "httpOnly": True, "secure": False, "sameSite": "Lax"} for c in admin.cookies]), encoding="utf-8")
    paths = ["/admin/dashboard", "/admin/movies", "/admin/movies/create", "/admin/movies/edit?id=" + FIXTURE["movie"], "/admin/categories", "/admin/categories/edit?id=" + FIXTURE["category"], "/admin/users", "/admin/users/edit?id=" + FIXTURE["regular"], "/admin/moderation"]
    for index, path in enumerate(paths):
        status, body, headers = admin.request(path)
        (OUT / ("page-" + str(index) + ".html")).write_text(body, encoding="utf-8")
        check(status == 200, "JSP render " + path + " status=" + str(status))
        check(headers.get("Cache-Control") == "no-store", "admin no-store " + path)
        check(not re.search(r"Business Rules|BR-\d|FR-\d|EntityManager|SQL Server|Hibernate", body), "product copy " + path)
    for path in ("/admin/movies?status=DELETED", "/admin/users?role=OWNER", "/admin/moderation?type=anything"):
        check(admin.request(path)[0] == 400, "invalid filter 400 " + path)
    check(admin.request("/admin/movies/delete")[0] == 404, "no physical movie deletion route")
    check(admin.request("/admin/movies/hide")[0] == 405, "GET hide cannot mutate")
    check(admin.request("/admin/users/update", method="GET")[0] == 405, "GET user update cannot mutate")
    for method in ("PATCH", "PUT", "DELETE", "HEAD"):
        check(admin.request("/admin/users", method=method)[0] == 405, "unsupported method 405 " + method)
    check(admin.request("/admin/users", {})[0] == 405, "POST list returns 405 before CSRF")
    _, category_form, category_headers = admin.request("/admin/categories")
    malformed_category={"name":"", "slug":"bad slug", "returnQ":"x"*201, "csrfToken":token(category_form,category_headers)}
    check(admin.request("/admin/categories/save", malformed_category)[0] == 400, "invalid category and malformed return filter retain 400")
    _, create, headers = admin.request("/admin/movies/create?q=verify&status=DRAFT&page=2")
    post = inputs(create)
    post.update(title="Phim kiểm chứng HTTP " + FIXTURE["suffix"], slug="verify-http-" + FIXTURE["suffix"] + "-" + uuid.uuid4().hex[:6], description="Nội dung tiếng Việt: điện ảnh và gia đình.", releaseYear="2026", durationMinutes="95", status="DRAFT", viewCount="999999", id="999999", createdAt="2000-01-01")
    (OUT / "http-slug").write_text(post["slug"])
    invalid = dict(post, title="", releaseYear="abc")
    status, body, _ = admin.request("/admin/movies/create", invalid)
    check(status == 400 and "abc" in body and post["slug"] in body, "field validation 400 preserves entered values")
    status, _, headers = admin.request("/admin/movies/create", post)
    check(status == 303 and "q=verify" in headers["Location"] and "status=DRAFT" in headers["Location"], "create 303 preserves filters")
    retry, _, _ = admin.request("/admin/movies/create", dict(post, slug=post["slug"] + "-retry"))
    check(retry == 303, "committed movie submission nonce retry succeeds without a second insert")
    _, listing, _ = admin.request("/admin/movies?q=" + post["slug"])
    match = re.search(r'/admin/movies/edit\?id=(\d+)', listing)
    assert match, "Created movie edit link missing"
    movie_id = match.group(1)
    (OUT / "http-movie-id").write_text(movie_id)
    _, edit, _ = admin.request("/admin/movies/edit?id=" + movie_id + "&q=verify&status=DRAFT&page=2")
    values = inputs(edit)
    check(values["returnQ"] == "verify" and values["returnStatus"] == "DRAFT" and values["returnPage"] == "2", "edit return filters retained")
    values.update(title="Kiểm chứng <script>alert('x')</script>", slug=post["slug"], description=post["description"], releaseYear="2026", durationMinutes="95", status="DRAFT")
    check(admin.request("/admin/movies/edit", values)[0] == 303, "movie edit committed")
    _, listing, _ = admin.request("/admin/movies?q=" + post["slug"])
    check("&lt;script&gt;" in listing and "<script>alert" not in listing, "database movie title escaped in JSP")
    check(admin.request("/admin/movies/hide", {"id": movie_id, "version": values["version"], "csrfToken": values["csrfToken"]})[0] == 409, "stale movie hide returns 409")
    _, edit, _ = admin.request("/admin/movies/edit?id=" + movie_id)
    values = inputs(edit)
    check(admin.request("/admin/movies/hide", {"id": movie_id, "version": values["version"], "csrfToken": values["csrfToken"]})[0] == 303, "movie hide committed")
    check(guest.request("/movies/detail?id=" + movie_id)[0] == 404, "hidden movie public detail 404")
    check(admin.request("/admin/movies/hide", {"id": FIXTURE["movie"], "version": "1"})[0] == 403, "missing CSRF blocks admin write")
    _, queue, _ = admin.request("/admin/moderation?type=review&status=PENDING&page=99999")
    review_form = next(part for part in re.findall(r'<form\b[^>]*>.*?</form>', queue, re.S) if inputs(part).get("id") == FIXTURE["review"])
    decision = inputs(review_form)
    decision["action"] = "APPROVE"
    check(admin.request("/admin/moderation/decide", decision)[0] == 303, "review moderation HTTP commit")
    check(admin.request("/admin/moderation/decide", decision)[0] == 303, "review moderation HTTP idempotent retry")
    for role, status, expected in (("ADMIN", "ACTIVE", 200), ("USER", "ACTIVE", 403), ("USER", "INACTIVE", 303)):
        _, user_form, _ = admin.request("/admin/users/edit?id=" + FIXTURE["regular"])
        user_values = inputs(user_form)
        user_values.update(role=role, status=status)
        check(admin.request("/admin/users/update", user_values)[0] == 303, "user role/status HTTP update " + role + "/" + status)
        check(regular.request("/admin/users")[0] == expected, "existing session observes current user permissions " + role + "/" + status)
    for path in ("/admin/movies?q=no-record-" + FIXTURE["suffix"], "/admin/categories?q=no-record-" + FIXTURE["suffix"], "/admin/users?q=no-record-" + FIXTURE["suffix"]):
        status, body, _ = admin.request(path)
        check(status == 200 and "mh-admin-empty" in body, "honest empty state " + path)
    for path in ("/assets/js/admin.js", "/assets/css/admin.css"):
        check(admin.request(path)[0] == 200, "served UTF-8 asset " + path)
    print("HTTP VERIFICATION COMPLETE")


if __name__ == "__main__":
    import sys
    if "--proof" in sys.argv:
        client=Client()
        client.login(FIXTURE["adminAEmail"])
        _, body, _=client.request("/admin/movies/edit?id="+FIXTURE["movie"])
        check("Hành trình qua miền ký ức "+FIXTURE["suffix"] in body, "DB fixture change reflected in served form without UI source changes")
    else:
        main()
