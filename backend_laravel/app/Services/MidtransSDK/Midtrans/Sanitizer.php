<?php

namespace Midtrans;

class Sanitizer
{
    private $filters;

    public function __construct()
    {
        $this->filters = array();
    }

    public static function jsonRequest(&$json)
    {
        $keys = array('item_details', 'customer_details');
        foreach ($keys as $key) {
            if (!isset($json[$key])) continue;
            $camel = static::upperCamelize($key);
            $function = "field$camel";
            static::$function($json[$key]);
        }
    }

    private static function fieldItemDetails(&$items)
    {
        foreach ($items as &$item) {
            $id = new self;
            $item['id'] = $id->maxLength(50)->apply($item['id']);
            $name = new self;
            $item['name'] = $name->maxLength(50)->apply($item['name']);
        }
    }

    private static function fieldCustomerDetails(&$field)
    {
        if (isset($field['first_name'])) {
            $first_name = new self;
            $field['first_name'] = $first_name->maxLength(255)->apply($field['first_name']);
        }
        if (isset($field['last_name'])) {
            $last_name = new self;
            $field['last_name'] = $last_name->maxLength(255)->apply($field['last_name']);
        }
        if (isset($field['email'])) {
            $email = new self;
            $field['email'] = $email->maxLength(255)->apply($field['email']);
        }
        if (isset($field['phone'])) {
            $phone = new self;
            $field['phone'] = $phone->maxLength(255)->apply($field['phone']);
        }
    }

    private function maxLength($length)
    {
        $this->filters[] = function ($input) use ($length) {
            return substr($input, 0, $length);
        };
        return $this;
    }

    private function apply($input)
    {
        foreach ($this->filters as $filter) {
            $input = call_user_func($filter, $input);
        }
        return $input;
    }

    private static function upperCamelize($string)
    {
        return str_replace(' ', '', ucwords(str_replace('_', ' ', $string)));
    }
}
