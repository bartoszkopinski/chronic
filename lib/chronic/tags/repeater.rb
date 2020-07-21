module Chronic
  class Repeater < Tag

    # Scan an Array of Token objects and apply any necessary Repeater
    # tags to each token.
    #
    # tokens - An Array of tokens to scan.
    # options - The Hash of options specified in Chronic::parse.
    #
    # Returns an Array of tokens.
    def self.scan(tokens, options)
      tokens.each do |token|
        token.tag scan_for_quarter_names(token, options)
        token.tag scan_for_season_names(token, options)
        token.tag scan_for_month_names(token, options)
        token.tag scan_for_day_names(token, options)
        token.tag scan_for_day_portions(token, options)
        token.tag scan_for_times(token, options)
        token.tag scan_for_units(token, options)
      end
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_quarter_names(token, options = {})
      scan_for token, RepeaterQuarterName,
      {
        /^q1$/ => :q1,
        /^q2$/ => :q2,
        /^q3$/ => :q3,
        /^q4$/ => :q4
      }, options
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_season_names(token, options = {})
      scan_for token, RepeaterSeasonName,
      {
        /^(springs?|wiosn[aą])$/ => :spring,
        /^(summers?|lato|latem)$/ => :summer,
        /^((autumn)|(fall)s?|jesieni[aą]|na jesie[nń])$/ => :autumn,
        /^(winters?|zim[ąa]|w zimie)$/ => :winter
      }, options
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_month_names(token, options = {})
      scan_for token, RepeaterMonthName,
      {
        /^(jan[:\.]?(uary)?|stycze[nń]|stycznia)$/ => :january,
        /^(feb[:\.]?(ruary)?|luty|lutego)$/ => :february,
        /^(mar[:\.]?(ch)?|marzec|marca)$/ => :march,
        /^(apr[:\.]?(il)?|kwiecie[nń]|kwietnia)$/ => :april,
        /^(may|maja?)$/ => :may,
        /^(jun[:\.]?e?|czerwiec|czerwca)$/ => :june,
        /^(jul[:\.]?y?|lipiec|lipca)$/ => :july,
        /^(aug[:\.]?(ust)?|sierpie[nń]|sierpnia)$/ => :august,
        /^(sep[:\.]?(t[:\.]?|tember)?|wrzesie[nń]|wrze[sś]nia)$/ => :september,
        /^(oct[:\.]?(ober)?|pa[zź]dziernika?)$/ => :october,
        /^(nov[:\.]?(ember)?|listopada?)$/ => :november,
        /^(dec[:\.]?(ember)?|grudzie[nń]|grudnia)$/ => :december
      }, options
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_day_names(token, options = {})
      scan_for token, RepeaterDayName,
      {
        /^(m[ou]n(day)?|poniedzia[lł]ek|pon|pn)$/ => :monday,
        /^(t(ue|eu|oo|u)s?(day)?|wtorek|wto?)$/ => :tuesday,
        /^(we(d|dnes|nds|nns)(day)?|[śs]r(oda)?)$/ => :wednesday,
        /^(th(u|ur|urs|ers)(day)?|czw(artek)?)$/ => :thursday,
        /^(fr[iy](day)?|pi[aą]tek|pt|pi[aą])$/ => :friday,
        /^(sat(t?[ue]rday)?|sobota|sb|sob)$/ => :saturday,
        /^(su[nm](day)?|niedziela|nd|niedz|ndz)$/ => :sunday
      }, options
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_day_portions(token, options = {})
      scan_for token, RepeaterDayPortion,
      {
        /^(ams?|przed po[lł]udniem)$/ => :am,
        /^(pms?|po po[lł]udniu)$/ => :pm,
        /^(mornings?|rano|rankiem)$/ => :morning,
        /^(afternoons?|popołudnie|popołudniami)$/ => :afternoon,
        /^(evenings?|wieczór|wieczorem|wieczorami)$/ => :evening,
        /^(nights?|nites?|noc|nocą|nocami|w nocy)$/ => :night
      }, options
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_times(token, options = {})
      scan_for token, RepeaterTime, /^\d{1,2}(:?\d{1,2})?([\.:]?\d{1,2}([\.:]\d{1,6})?)?$/, options
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_units(token, options = {})
      {
        /^years?|rok|lata$/ => :year,
        /^q$/ => :quarter,
        /^seasons?$/ => :season,
        /^(months?|miesi[eęaą]c[yeua]?)$/ => :month,
        /^fortnights?$/ => :fortnight,
        /^(weeks?|tydzie[nń]|tygodni[eu]?)$/ => :week,
        /^weekends?$/ => :weekend,
        /^(week|business)days?$/ => :weekday,
        /^(days?|dzie[nń]|dni)$/ => :day,
	      /^(hrs?|godz\.?)$/ => :hour,
        /^(hours?|godzin[eęay]?)$/ => :hour,
	      /^mins?$/ => :minute,
        /^(minutes?|minut[ęay]?)$/ => :minute,
	      /^(secs?|sek)$/ => :second,
        /^(seconds?|sekund[ęya]?)$/ => :second
      }.each do |item, symbol|
        if item =~ token.word
          klass_name = 'Repeater' + symbol.to_s.capitalize
          klass = Chronic.const_get(klass_name)
          return klass.new(symbol, nil, options)
        end
      end
      return nil
    end

    def <=>(other)
      width <=> other.width
    end

    # returns the width (in seconds or months) of this repeatable.
    def width
      raise('Repeater#width must be overridden in subclasses')
    end

    # returns the next occurance of this repeatable.
    def next(pointer)
      raise('Start point must be set before calling #next') unless @now
    end

    def this(pointer)
      raise('Start point must be set before calling #this') unless @now
    end

    def to_s
      'repeater'
    end
  end
end
