<?php

namespace Midtrans;

class Config
{
    public static $serverKey;
    public static $clientKey;
    public static $isProduction = false;
    public static $is3ds = false;
    public static $appendNotifUrl;
    public static $overrideNotifUrl;
    public static $paymentIdempotencyKey;
    public static $isSanitized = false;
    public static $curlOptions = array();

    const SANDBOX_BASE_URL = 'https://api.sandbox.midtrans.com';
    const PRODUCTION_BASE_URL = 'https://api.midtrans.com';
    const SNAP_SANDBOX_BASE_URL = 'https://app.sandbox.midtrans.com/snap/v1';
    const SNAP_PRODUCTION_BASE_URL = 'https://app.midtrans.com/snap/v1';

    public static function getBaseUrl()
    {
        return Config::$isProduction ?
        Config::PRODUCTION_BASE_URL : Config::SANDBOX_BASE_URL;
    }

    public static function getSnapBaseUrl()
    {
        return Config::$isProduction ?
        Config::SNAP_PRODUCTION_BASE_URL : Config::SNAP_SANDBOX_BASE_URL;
    }
}
