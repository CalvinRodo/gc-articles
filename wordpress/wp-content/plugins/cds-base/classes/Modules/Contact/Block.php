<?php

namespace CDS\Modules\Contact;

use CDS\Modules\Contact\ContactForm;
use CDS\Utils;

class Block
{
    public function __construct()
    {
        add_action('plugins_loaded', [ $this, 'init' ]);
    }

    public function init(): void
    {
        add_action('init', [ $this, 'registerBlock' ]);
    }

    public function registerBlock()
    {
        if (!is_super_admin() && !Utils::isWpEnv()) {
            return;
        }

        register_block_type_from_metadata(
            __DIR__,
            [
                'render_callback' => [ $this, 'renderCallback' ],
                'attributes' => [
                    'placeholderValue' => [
                        'type' => 'string',
                        "default" => "preview@example.com"
                    ]
                ]
            ]
        );
    }

    public function renderCallback($attributes, $content, $block): string
    {
        $form = new ContactForm();
        return $form->render($attributes);
    }
}
