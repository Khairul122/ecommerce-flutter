<?php

namespace Midtrans;

use Exception;

class Snap
{
    public static function getSnapToken($params)
    {
        return (Snap::createTransaction($params)->token);
    }

    public static function getSnapUrl($params)
    {
        return (Snap::createTransaction($params)->redirect_url);
    }

    public static function createTransaction($params)
    {
        $payloads = array(
            'credit_card' => array(
                'secure' => Config::$is3ds
            )
        );

        if (isset($params['item_details'])) {
            $gross_amount = 0;
            foreach ($params['item_details'] as $item) {
                $gross_amount += $item['quantity'] * $item['price'];
            }
            $params['transaction_details']['gross_amount'] = $gross_amount;
        }

        if (Config::$isSanitized) {
            Sanitizer::jsonRequest($params);
        }

        $params = array_replace_recursive($payloads, $params);

        return ApiRequestor::post(
            Config::getSnapBaseUrl() . '/transactions',
            Config::$serverKey,
            $params
        );
    }
}
