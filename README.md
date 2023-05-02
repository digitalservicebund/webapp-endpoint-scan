# Web application security scans

## Purpose

A collection of scans to ensure that we use state of the art settings for:

* [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0,_2.0,_and_3.0)
* [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields)

## Quickstart / Run

Call `run.sh <hostname>` to run baseline checks. Find results in `results/<hostname>` directory.

### Check cookie flags

Find more information on `Secure` and `HttpOnly` on 
[Mozilla's MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#secure).

If you want to check secure cookie settings call `run.sh <hostname> <cookie-path>` where `<cookie-path>` defines
the absolute path where `Set-Cookie` headers are provided. Example: `run.sh www.example.org /set/cookie/path`

## Tools used

### sslyze - analyze TLS (a.k.a. SSL) configuration compliance with Mozilla profiles

Find more information on the recommended TLS profiles at [Mozilla](https://wiki.mozilla.org/Security/Server_Side_TLS).

Install sslyze: `pip3 install sslyze`

Run sslyze: `sslyze --json_out ./ssl-test-result.json www.example.org`

### venom - check for OWASP security headers recommendation

Find more information on recommended HTTP security header settings at
[OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/).

A very informative and recommended tool for on demand scans is [securityheaders.com](https://securityheaders.com).
Do not forget to tick **Hide results** checkbox if you do not want to publish the scan results on
`securityheaders.com`.

OWASP provides a [venom](https://github.com/ovh/venom) tests suite to validate an HTTP security response header configuration.
A copy of the [original test suite](https://github.com/oshp/oshp-validator/blob/main/tests_suite.yml) can also be found
in `tests/owasp_secure_headers_test_suite.yml`.

For Digitalservice Bund we use the base recommendations from [securityheaders.com](https://securityheaders.com).
The tests are configured in `tests/dsbund_secure_headers_test_suite.yml`.

Both test suites can easily be switched in `run.sh`.

The venom tests suite can be run standalone [using docker](https://github.com/ovh/venom#docker-image).

```sh
mkdir -p results
docker run \
    --mount type=bind,source=$(pwd)/tests,target=/workdir/tests \
    --mount type=bind,source=$(pwd)/results,target=/workdir/results \
    ovhcom/venom:latest 
```

