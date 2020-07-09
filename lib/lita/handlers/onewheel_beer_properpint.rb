require 'rest-client'
require 'lita-onewheel-beer-base'

module Lita
  module Handlers
    class OnewheelBeerProperPint < OnewheelBeerBase
      route /^proper$/i,
            :taps_list,
            command: true,
            help: {'proper' => 'Display the current taps.'}

      route /^proper ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'proper 4' => 'Display the tap 4 deets, including prices.'}

      route /^proper (roulette|random)$/i,
            :taps_by_random,
            command: true,
            help: {'proper roulette' => 'Can\'t decide?  Let me do it for you!'}

      def taps_list(response)
        # wakka wakka
        beers = self.get_source
        reply = "Proper's taps: "
        beers.each do |tap, datum|
          reply += "#{tap}) "
          reply += get_tap_type_text(datum[:type])
          reply += (datum[:name].to_s.empty?)? '' : datum[:name].to_s + '  '
        end
        reply = reply.strip.sub /,\s*$/, ''

        reply += "   Order now at https://my-site-109373-104980.square.site/dine-in"
        Lita.logger.info "Replying with #{reply}"
        response.reply reply
      end

      def send_response(tap, datum, response)
        reply = "Proper's tap #{tap}) #{get_tap_type_text(datum[:type])}"
        reply += "#{datum[:name]} "
        # reply += "- #{datum[:desc]}, "
        # reply += "Served in a #{datum[1]['glass']} glass.  "

        Lita.logger.info "send_response: Replying with #{reply}"

        response.reply reply
      end

      def get_source
        # unless (response = redis.get('page_response'))
        #   Lita.logger.info 'No cached result found, fetching.'
        url = 'https://my-site-109373-104980.square.site/dine-in'
        Lita.logger.info "Getting #{url}"
        response = RestClient.get(url)
          # redis.setex('page_response', 1800, response)
        # end
        parse_response response
      end

      # This is the worker bee- decoding the html into our "standard" document.
      # Future implementations could simply override this implementation-specific
      # code to help this grow more widely.
      def parse_response(response)
        Lita.logger.debug "parse_response started."
        gimme_what_you_got = {}
        valid_products = {}
        products = {}
        response.split(/\n/).each do |line|
          if matches = line.match(/window.siteData = (.*)/)
            site_hash = JSON.parse matches[1].sub /;$/, ''
            valid_products = site_hash['page']['properties']['contentAreas']['userContent']['content']['cells'][0]['content']['properties']['products']
          end
          if matches = line.match(/window.__BOOTSTRAP_STATE__ = (.*)/)
            whatevenintheshitsquarespace = JSON.parse matches[1].sub /;$/, ''
            products = whatevenintheshitsquarespace['commerceLinks']['products']
          end
        end

        valid_products
        products
        live_products = []

        valid_products.each do |p|
          live_products.push products[p]  unless products[p].nil?
        end

        live_products.each_with_index do |beer, idx|
          tap = idx + 1
          tap_type = ''
          beer_name = beer['name'].sub(/ 32oz Crowler/, '')
          full_text_search = "#{tap} #{beer_name}"

          gimme_what_you_got[tap] = {
              type: tap_type,
              name: beer_name.to_s,
              search: full_text_search
          }
        end

        gimme_what_you_got
      end

      # Return the desc of the beer, "Amber ale 6.9%"
      def get_beer_desc(noko)
        beer_desc = ''
        if (beer_desc_matchdata = noko.to_s.gsub(/\n/, '').match(/(<br\s*\/*>)(.+%) /))
          beer_desc = beer_desc_matchdata[2].gsub(/\s+/, ' ').strip
        end
        beer_desc
      end

      Lita.register_handler(self)
    end
  end
end
