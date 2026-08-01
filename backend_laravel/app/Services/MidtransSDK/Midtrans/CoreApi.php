<?php

namespace Midtrans;

class CoreApi
{
    public static function charge($params)
    {
        if (Config::$isSanitized) {
            Sanitizer::jsonRequest($params);
        }
        return ApiRequestor::post(
            Config::getBaseUrl() . '/v2/charge',
            Config::$serverKey,
            $params
        );
    }
}
