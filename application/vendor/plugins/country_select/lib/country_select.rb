# CountrySelect
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end
      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""

        if priority_countries
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

        return country_options + options_for_select(COUNTRIES, selected)
      end
      # All the countries included in the country_options output.
      COUNTRIES =  ["afghanistan", "aland_islands", "albania", "algeria", "american_samoa", "andorra", "angola", "anguilla", "antarctica", "antigua_and_barbuda", "argentina", "armenia", "aruba", "australia", "austria", "azerbaijan", "bahamas", "bahrain", "bangladesh", "barbados", "belarus", "belgium", "belize", "benin", "bermuda", "bhutan", "bolivia", "bosnia_and_herzegowina", "botswana", "bouvet_island", "brazil", "british_indian_ocean_territory", "brunei_darussalam", "bulgaria", "burkina_faso", "burundi", "cambodia", "cameroon", "canada", "cape_verde", "cayman_islands", "central_african_republic", "chad", "chile", "china", "christmas_island", "cocos_keeling_islands", "colombia", "comoros", "congo", "cook_islands", "costa_rica", "cote_ivoire", "croatia", "cuba", "cyprus", "czech_republic", "denmark", "djibouti", "dominica", "dominican_republic", "ecuador", "egypt", "el_salvador", "equatorial_guinea", "eritrea", "estonia", "ethiopia", "falkland_islands_malvinas", "faroe_islands", "fiji", "finland", "france", "french_guiana", "french_polynesia", "french_southern_territories", "gabon", "gambia", "georgia", "germany", "ghana", "gibraltar", "greece", "greenland", "grenada", "guadeloupe", "guam", "guatemala", "guernsey", "guinea", "guinea_bissau", "guyana", "haiti", "heard_and_mcdonald_islands", "holy_see_vatican_city_state", "honduras", "hong_kong", "hungary", "iceland", "india", "indonesia", "iran_islamic_republic_of", "iraq", "ireland", "isle_of_man", "israel", "italy", "jamaica", "japan", "jersey", "jordan", "kazakhstan", "kenya", "kiribati", "korea_democratic_peoples_republic_of", "korea_republic_of", "kuwait", "kyrgyzstan", "lao_peoples_democratic_republic", "latvia", "lebanon", "lesotho", "liberia", "libyan_arab_jamahiriya", "liechtenstein", "lithuania", "luxembourg", "macao", "macedonia_the_former_yugoslav_republic_of", "madagascar", "malawi", "malaysia", "maldives", "mali", "malta", "marshall_islands", "martinique", "mauritania", "mauritius", "mayotte", "mexico", "micronesia_federated_states_of", "moldova_republic_of", "monaco", "mongolia", "montenegro", "montserrat", "morocco", "mozambique", "myanmar", "namibia", "nauru", "nepal", "netherlands", "netherlands_antilles", "new_caledonia", "new_zealand", "nicaragua", "niger", "nigeria", "niue", "norfolk_island", "northern_mariana_islands", "norway", "oman", "pakistan", "palau", "palestinian_territory_occupied", "panama", "papua_new_guinea", "paraguay", "peru", "philippines", "pitcairn", "poland", "portugal", "puerto_rico", "qatar", "reunion", "romania", "russian_federation", "rwanda", "saint_barthelemy", "saint_helena", "saint_kitts_and_nevis", "saint_lucia", "saint_pierre_and_miquelon", "saint_vincent_and_the_grenadines", "samoa", "san_marino", "sao_tome_and_principe", "saudi_arabia", "senegal", "serbia", "seychelles", "sierra_leone", "singapore", "slovakia", "slovenia", "solomon_islands", "somalia", "south_africa", "south_georgia_and_the_south_sandwich_islands", "spain", "sri_lanka", "sudan", "suriname", "svalbard_and_jan_mayen", "swaziland", "sweden", "switzerland", "syrian_arab_republic", "taiwan_province_of_china", "tajikistan", "tanzania_united_republic_of", "thailand", "timor_leste", "togo", "tokelau", "tonga", "trinidad_and_tobago", "tunisia", "turkey", "turkmenistan", "turks_and_caicos_islands", "tuvalu", "uganda", "ukraine", "united_arab_emirates", "united_kingdom", "united_states", "united_states_minor_outlying_islands", "uruguay", "uzbekistan", "vanuatu", "venezuela", "vietnam", "virgin_islands_british", "virgin_islands_us", "wallis_and_futuna", "western_sahara", "yemen", "zambia", "zimbabwe"].sort.collect{|c| [I18n.t("countries." + c), c]} unless const_defined?("COUNTRIES")
    end
    
    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            country_options_for_select(value, priority_countries),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
    end
  end
end
