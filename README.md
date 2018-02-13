# Kong Upstream Header JWT Builder Plugin

## Introduction
This plugin will construct JWT from value obtained from upstream header of authentication plugins which is set during authentication. This must run before authentication plugins. The upstream header to be transformed to JWT is configured in the plugin.

This can be used by authentication services to add more consumer information as claims. These claims can be used by upstream services to respond with corresponding data.

This plugin will set the upstream header provided by authentication plugin (see corresponding documentation) before authentication so that for subsequent request this plugin won't do anything.

## Supported Kong Releases
Kong >= 0.11.x

## Installation
Recommended:
```
$ luarocks install kong-up-jwt-builder
```

## Usage Instructions
1. Add header names while applying plugin which carries the payload during the authentication request that to be transformed into JWT.

## Plugin Configuration
Form Parameter | Default | Description
-------------- |---------|------------
key            |         | secret key for signing.
alg            | HS256   | JWS signing algorithm.
headers        |         | A list of header names set by authentication plugin for upstream.
dialect        |http://example.com/claims/| A URI under which claims are looked for.
issuer         |example.com/plugins/up-jwt-builder| JWT iss claim.
audience       |         | JWT aud claim.
expiration     |         | JWT exp cliam in seconds.

### Notes
1. Registered claims can be overwrite by the claims in the upstream header payload.

This plugin was designed to work with the `kong-vagrant` 
[development environment](https://github.com/Mashape/kong-vagrant). Please
checkout that repos `readme` for usage instructions.
