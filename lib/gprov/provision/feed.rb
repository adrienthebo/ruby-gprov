require 'nokogiri'

require 'gprov'
require 'gprov/provision/entrybase/xmlattr'

#
# Generic representation of the various types of feeds available from the
# provisioning API.
#
# The Google Provisioning API has constructs for both entries and feeds, so
# for instance there is a discrete UserEntry and a UserFeed. However, the
# feeds are all formatted in the same manner, so instead we just create a
# single feed class that can return arrays of actual Entry classes.
#
# This mainly serves to instantiate Entry objects, so users of the GProv
# library shouldn't have to use this.
#
# @see https://developers.google.com/google-apps/provisioning/#sample_nicknamefeed_response An example of a specific feed: NicknameFeed
# @see https://developers.google.com/google-apps/provisioning/reference#Results_Pagination Google Provisioning API Results Pagination
class GProv::Provision::Feed

  # @param [Connection] connection The Connection object used to connect to Google
  # @param [String] url The Feed URL to start fetching paged results from.
  def initialize(connection, url, xpath)
    @connection = connection
    @url        = url
    @xpath      = xpath
  end

  # Fetch all entries in a feed, and ignore any cached entries. Accepts an
  # optional block that will be fed each page of entries.
  #
  # This can be used to force a new fetch, but might cause unneeded overhead.
  # You probably want #fetch.
  #
  # @yield [Array<Nokogiri::XML::node>] The results of the last page fetch
  # @return [Array<Nokogiri::XML::node>] The aggregated results
  def fetch!(&block)
    @results = []
    link = @url

    until link.nil?
      document = retrieve(link)
      results  = parse(document)
      link     = results[:nextpage]
      entries  = results[:entries]

      yield entries if block_given?
    end
    @results
  end

  # Return all entries in a feed. If they don't exist, fetch and cache them. If
  # they exist, return the cache.
  #
  # @yield [Array<Nokogiri::XML::node>] The results of the last page fetch
  # @return [Array<Nokogiri::XML::node>] The aggregated results
  def fetch(&block)
    fetch! &block unless @results
    @results
  end

  private

  # Retrieves a page of results.
  def retrieve(url)
    response = @connection.get(url)

    if response.success?
      response.body
    else
      raise RuntimeError, "Failed to retrieve #{url}: HTTP #{response.code} #{response.body}"
    end
  end

  # Given an XML document, returns an array of the desired entries and a
  # link to the next page in the feed.
  def parse(xml)

    document = Nokogiri::XML(xml)
    entries = document.xpath(@xpath)
    @results.concat(entries.to_a)

    {:entries => entries, :nextpage => atomlink(document)}
  end

  # Attempt to retrieve the atom:link tag if it's contained in the
  # given document, indicating that there are more paginated results.
  def atomlink(xml)
    # Effectively memoize this XMLAttr object, since we can use it for
    # every parsed page.
    @atomlink ||= GProv::Provision::EntryBase::XMLAttr.new(:link, :xpath => %{/xmlns:feed/xmlns:link[@rel = "next"]/@href})

    # REVIEW This might be utilizing behavior that's unexpected. This
    # retrieves a fully qualified URL, which means that it might be
    # bypassing some of the logic in the GProv::Conection code. Instead of
    # passing in the base resource URI like the rest of GProv, we're
    # blindly using this
    #
    # So instead of retrieving this:
    #
    #   /group/2.0/:domain/<group>@<domain>/member?start=<string>
    #
    # We're retrieving this:
    #
    # https://apps-apis.google.com/a/feeds/group/2.0/<domain>/<group>@<domain>/member?start=<string>
    #
    # This works, since by the nature of this request the group and domain
    # are filled in correctly. However, it ignores the baseuri respected by
    # the rest of this library, the :domain symbol, and other behaviors.
    # This should continue to work, but if HTTParty stops allowing fully
    # qualified URLs like this and merely prepends the current baseuri to
    # this string then the world will explode.
    link = @atomlink.parse(xml)
    link unless link.empty?
  end
end
