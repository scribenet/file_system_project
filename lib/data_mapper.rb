require 'nokogiri'
require 'ostruct'

class DataMapper
  attr_reader :mapper
  def initialize(string)
    @doc = Nokogiri.XML(string)
    @mapper = map(@doc.root)
  end

  def plural(string)
    string + 's'
  end

  def adder(el)
    el.elements.empty? ? el.text : map(el)
  end

  def map(main_el)
    obj = OpenStruct.new
    main_el.elements.each do |el|
      plur = plural(el.name)
      if obj.respond_to?(plur)
        obj.send(plur) << adder(el)
      elsif main_el.css(el.name).size > 1
        obj.send("#{plur}=", [])
        obj.send(plur) << adder(el) 
      elsif el.elements.empty?
        obj.send("#{el.name}=", el.text)
      else
        obj.send("#{el.name}=", map(el))
      end
    end 
    obj
  end 
end
