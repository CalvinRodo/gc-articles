<?php

namespace CDS\Modules\Notify;

use WP_User;

class ListManagerUserProfile
{
    public function __construct()
    {
    }

    public static function register()
    {
        $instance = new self();

        add_action('edit_user_profile', [$instance, 'displayListManagerMeta']);

        add_action('personal_options_update', [$instance, 'updateListManagerMeta']);
        add_action('edit_user_profile_update', [$instance,'updateListManagerMeta']);
    }

    public function displayListManagerMeta($user)
    {
        if (!is_super_admin()) {
            return;
        }

        $list_manager_bulk_send = user_can($user, "list_manager_bulk_send");

        if ($list_manager_bulk_send) {
            $checked = 'checked';
        } else {
            $checked = '';
        }

        printf('<h3>%s</h3>', __('GC Lists', 'cds-snc'));
        print "<table class='form-table'>";

        print '<tr>';
        printf(
            "<th><label for='list_manager_bulk_send'>%s</label></th>",
            __('Bulk Send', 'cds-snc'),
        );
        printf(
            "<td><input value='true' type='checkbox' name='list_manager_bulk_send' id='list_manager_bulk_send' %s /> %s</td>",
            $checked,
            __('Allow bulk send', 'cds-snc'),
        );

        $list_manager_bulk_send_sms = user_can($user, "list_manager_bulk_send_sms");

        if ($list_manager_bulk_send_sms) {
            $sms_checked = 'checked';
        } else {
            $sms_checked = '';
        }

        print '<tr>';
        printf(
            "<th><label for='list_manager_bulk_send_sms'>%s</label></th>",
            __('Bulk Send SMS', 'cds-snc'),
        );
        printf(
            "<td><input value='true' type='checkbox' name='list_manager_bulk_send_sms' id='list_manager_bulk_send_sms' %s /> %s</td>",
            $sms_checked,
            __('Allow bulk send SMS', 'cds-snc'),
        );

        print '</tr>';
        print '</table>';
    }

    public function updateListManagerMeta($userId)
    {
        if (!is_super_admin()) {
            return;
        }

        $user = new WP_User($userId);
        $user->remove_cap('list_manager_bulk_send');
        $user->remove_cap('list_manager_bulk_send_sms');

        if (isset($_POST['list_manager_bulk_send']) && $_POST['list_manager_bulk_send'] === "true") {
            $user->add_cap('list_manager_bulk_send');
        }

        if (isset($_POST['list_manager_bulk_send_sms']) && $_POST['list_manager_bulk_send_sms'] === "true") {
            $user->add_cap('list_manager_bulk_send_sms');
        }
    }
}
