(function () {
    'use strict';
    var dialog = document.getElementById('admin-confirm');
    var pendingForm = null;
    var pendingSubmitter = null;
    var restoreTarget = null;
    var acceptedForm = null;

    function closeConfirmation() {
        if (dialog && dialog.open) dialog.close();
        pendingForm = null;
        pendingSubmitter = null;
        if (restoreTarget && restoreTarget.isConnected) restoreTarget.focus();
    }

    function confirmationFor(form) {
        if (form.dataset.confirmKind === 'movie') {
            var movieStatus = form.elements.namedItem('status');
            if (!movieStatus) return null;
            var title = form.elements.namedItem('title').value;
            if (movieStatus.value === 'HIDDEN' && form.dataset.currentStatus !== 'HIDDEN') return form.dataset.confirmHide.replace('{title}', title);
            if (movieStatus.value === 'PUBLISHED' && form.dataset.currentStatus !== 'PUBLISHED') return form.dataset.confirmPublish.replace('{title}', title);
            return null;
        }
        if (form.dataset.confirmKind === 'user') {
            var role = form.elements.namedItem('role');
            var status = form.elements.namedItem('status');
            if ((status && status.value === 'INACTIVE' && form.dataset.currentStatus !== 'INACTIVE') ||
                (role && role.value === 'USER' && form.dataset.currentRole === 'ADMIN')) return form.dataset.confirm;
            return null;
        }
        return form.dataset.confirm || null;
    }

    document.addEventListener('submit', function (event) {
        var form = event.target;
        if (!(form instanceof HTMLFormElement)) return;
        if (form.dataset.submitting === 'true') { event.preventDefault(); return; }
        var message = confirmationFor(form);
        if (message && acceptedForm !== form) {
            if (!dialog || typeof dialog.showModal !== 'function') {
                if (!window.confirm(message)) event.preventDefault();
                return;
            }
            event.preventDefault();
            pendingForm = form;
            pendingSubmitter = event.submitter;
            restoreTarget = event.submitter || document.activeElement;
            document.getElementById('confirm-description').textContent = message;
            dialog.querySelector('[data-confirm-accept]').textContent = form.dataset.confirmAction || dialog.dataset.defaultAction;
            dialog.showModal();
            dialog.querySelector('[data-confirm-cancel]').focus();
            return;
        }
        acceptedForm = null;
        if (form.method.toLowerCase() === 'post') form.dataset.submitting = 'true';
        if (event.submitter && form.dataset.savingLabel) {
            event.submitter.textContent = form.dataset.savingLabel;
            event.submitter.setAttribute('aria-disabled', 'true');
            var submittedButton = event.submitter;
            window.setTimeout(function () { submittedButton.disabled = true; }, 0);
        }
    });

    if (dialog) {
        dialog.dataset.defaultAction = dialog.querySelector('[data-confirm-accept]').textContent;
        dialog.querySelector('[data-confirm-cancel]').addEventListener('click', closeConfirmation);
        dialog.addEventListener('cancel', function (event) { event.preventDefault(); closeConfirmation(); });
        dialog.querySelector('[data-confirm-accept]').addEventListener('click', function () {
            var form = pendingForm;
            var submitter = pendingSubmitter;
            closeConfirmation();
            if (form) {
                acceptedForm = form;
                form.requestSubmit(submitter || undefined);
            }
        });
        dialog.addEventListener('keydown', function (event) {
            if (event.key !== 'Tab') return;
            var buttons = dialog.querySelectorAll('button:not(:disabled)');
            var first = buttons[0];
            var last = buttons[buttons.length - 1];
            if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
            if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
        });
    }

    document.querySelectorAll('[data-admin-menu]').forEach(function (menu) {
        menu.addEventListener('keydown', function (event) {
            if (event.key === 'Escape' && menu.open) {
                menu.open = false;
                menu.querySelector('summary').focus();
            }
        });
        document.addEventListener('click', function (event) { if (!menu.contains(event.target)) menu.open = false; });
    });

    document.querySelectorAll('[data-poster]').forEach(function (poster) {
        function usePlaceholder() {
            var placeholder = document.createElement('span');
            placeholder.className = poster.className;
            placeholder.setAttribute('aria-hidden', 'true');
            poster.replaceWith(placeholder);
        }
        poster.addEventListener('error', usePlaceholder, { once: true });
        if (poster.complete && poster.naturalWidth === 0) usePlaceholder();
    });

    var errors = document.querySelector('[data-error-summary]');
    if (errors) errors.focus();

    // Studio Sidebar Drawer Controls
    var sidebarToggle = document.getElementById('sidebar-toggle');
    var sidebarClose = document.getElementById('sidebar-close');
    var sidebarBackdrop = document.getElementById('sidebar-backdrop');

    function openSidebar() {
        document.body.classList.add('mh-sidebar-open');
    }
    function closeSidebar() {
        document.body.classList.remove('mh-sidebar-open');
    }

    if (sidebarToggle) sidebarToggle.addEventListener('click', openSidebar);
    if (sidebarClose) sidebarClose.addEventListener('click', closeSidebar);
    if (sidebarBackdrop) sidebarBackdrop.addEventListener('click', closeSidebar);

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && document.body.classList.contains('mh-sidebar-open')) {
            closeSidebar();
        }
    });

    // YouTube Studio SVG Line & Area Chart Engine
    var chartPoints = document.querySelectorAll('.mh-chart-point');
    var chartLine = document.getElementById('studio-chart-line');
    var chartArea = document.getElementById('studio-chart-area');
    var hoverLine = document.getElementById('chart-hover-line');
    var tooltip = document.getElementById('chart-tooltip');
    var chartContainer = document.getElementById('chart-container');

    if (chartPoints.length > 0 && chartLine && chartArea) {
        var pts = [];
        chartPoints.forEach(function (pt) {
            pts.push({
                x: parseFloat(pt.getAttribute('cx')),
                y: parseFloat(pt.getAttribute('cy')),
                element: pt
            });
        });

        // Generate smooth cubic bezier path
        var pathD = 'M ' + pts[0].x + ' ' + pts[0].y;
        for (var i = 1; i < pts.length; i++) {
            var prev = pts[i - 1];
            var curr = pts[i];
            var cpX = (prev.x + curr.x) / 2;
            pathD += ' C ' + cpX + ' ' + prev.y + ', ' + cpX + ' ' + curr.y + ', ' + curr.x + ' ' + curr.y;
        }

        chartLine.setAttribute('d', pathD);

        // Fill area down to baseline at y=200
        var areaD = pathD + ' L ' + pts[pts.length - 1].x + ' 200 L ' + pts[0].x + ' 200 Z';
        chartArea.setAttribute('d', areaD);

        // Interactive hover cards
        var viewUnit = '\u006c\u01b0\u1ee3\u0074\u0020\u0078\u0065\u006d'; // "lượt xem"

        pts.forEach(function (pt) {
            function showPointCard(e) {
                var rank = pt.element.dataset.rank;
                var title = pt.element.dataset.title;
                var views = Number(pt.element.dataset.views || 0);
                var year = pt.element.dataset.year;

                if (hoverLine) {
                    hoverLine.setAttribute('x1', pt.x);
                    hoverLine.setAttribute('x2', pt.x);
                    hoverLine.style.display = 'block';
                }

                pt.element.setAttribute('r', '9');
                pt.element.classList.add('is-active-point');

                if (tooltip && chartContainer) {
                    tooltip.innerHTML = '<div class="mh-tt-rank">#' + rank + (year ? ' \u2022 ' + year : '') + '</div>' +
                                        '<div class="mh-tt-title">' + title + '</div>' +
                                        '<div class="mh-tt-views">' + views.toLocaleString() + ' ' + viewUnit + '</div>';
                    tooltip.style.display = 'block';

                    var rect = chartContainer.getBoundingClientRect();
                    var svgWidth = 760;
                    var svgHeight = 260;
                    var scaleX = rect.width / svgWidth;
                    var scaleY = rect.height / svgHeight;

                    var tipLeft = (pt.x * scaleX);
                    var tipTop = (pt.y * scaleY) - 16;

                    tooltip.style.left = tipLeft + 'px';
                    tooltip.style.top = tipTop + 'px';
                }
            }

            function hidePointCard() {
                pt.element.setAttribute('r', '6');
                pt.element.classList.remove('is-active-point');
                if (hoverLine) hoverLine.style.display = 'none';
                if (tooltip) tooltip.style.display = 'none';
            }

            pt.element.addEventListener('mouseenter', showPointCard);
            pt.element.addEventListener('focus', showPointCard);
            pt.element.addEventListener('mouseleave', hidePointCard);
            pt.element.addEventListener('blur', hidePointCard);
        });

        if (chartContainer) {
            chartContainer.addEventListener('mouseleave', function () {
                if (hoverLine) hoverLine.style.display = 'none';
                if (tooltip) tooltip.style.display = 'none';
                pts.forEach(function (pt) { pt.element.setAttribute('r', '6'); });
            });
        }
    }
}());
