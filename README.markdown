Ruby-GProv
==========

Synopsis
--------

This is a ruby implementation of the Ruby implementation of the [Google Provisioning API][api].

Description
-----------

The specification of the Google Provisioning API is primarily procedural in
nature, despite that all the languages that Google provides bindings for are
object oriented. This implementation attempts to provide a more natural
interface to that API. Where applicable, objects present a CRUD-like set of
methods to perform operations on the underlying system.

[api]: http://code.google.com/googleapps/domain/gdata_provisioning_api_v2.0_reference.html "Google Provisioning API v2.0"

- - -

Examples
--------

[gtool](https://github.com/adrienthebo/gtool) - a command line interface to the
provisioning API.

Development
-----------

  * Source: https://github.com/adrienthebo/ruby-gprov
  * Issues: https://github.com/adrienthebo/ruby-gprov/issues

This is alpha software. While I've done extensive real world testing of this
myself, it's not feature complete and doesn't have enough test coverage. Please
file bug reports and let me know where it's lacking; I'm very interested in
improving it!
