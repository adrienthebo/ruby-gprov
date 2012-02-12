require 'gprov'

class FakeEntry < GProv::Provision::EntryBase

  xmlattr :test, :xpath => "/foo/bar/text()"
end
