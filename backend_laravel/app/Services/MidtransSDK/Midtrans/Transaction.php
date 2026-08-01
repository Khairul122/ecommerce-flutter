<?php

namespace Midtrans;

use Exception;

class Transaction
{
    public static function status($id)
    {
        return ApiRequestor::get(
            Config::getBaseUrl() . '/v2/' . $id . '/status',
            Config::$serverKey,
            false
        );
    }

    public static function statusB2b($id)
    {
        return ApiRequestor::get(
            Config::getBaseUrl() . '/v2/' . $id . '/status/b2b',
            Config::$serverKey,
            false
        );
    }

    public static function approve($id)
    {
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/' . $id . '/approve',
            Config::$serverKey,
            false
        )->status_code;
    }

    public static function cancel($id)
    {
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/' . $id . '/cancel',
            Config::$serverKey,
            false
        )->status_code;
    }

    public static function expire($id)
    {
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/' . $id . '/expire',
            Config::$serverKey,
            false
        );
    }

    public static function refund($id, $params)
    {
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/' . $id . '/refund',
            Config::$serverKey,
            $params
        );
    }

    public static function refundDirect($id, $params)
    {
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/' . $id . '/refund/online/direct',
            Config::$serverKey,
            $params
        );
    }

    public static function deny($id)
    {
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/' . $id . '/deny',
            Config::$serverKey,
            false
        );
    }
}
