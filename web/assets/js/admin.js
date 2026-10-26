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
}());
