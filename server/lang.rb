# frozen_string_literal: true

def lang(text, *args)
  args.each_index do |i|
    text.sub!("!#{i+1}!", args[i].to_s)
  end
  text
end

LOG.fatal('Codice lingua non valido') unless File.exist?("lang/#{CONFIG[:lang]}.rb")

require_relative "lang/#{CONFIG[:lang]}.rb"
