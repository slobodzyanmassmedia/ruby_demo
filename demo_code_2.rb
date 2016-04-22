# Generate XML document
class XmlDocument

  def initialize(format = false)
    @format = format
    @nested = 0
  end

  def method_missing(m, *args, &block)
    @nested += 1
    arguments = []
    unless args[0] == nil
      args[0].each { |key, val| arguments.push "#{key.to_s}='#{val}'" }
    end
    arguments = arguments.join ' '.to_s
    arguments = " #{arguments}" if arguments.length > 0
    spaces = ' ' * ((@nested - 1) * 2)
    if @format
      block ? "#{spaces}<#{m}#{arguments}>\n#{block.call}#{spaces}</#{m}>\n" : "#{spaces}<#{m}#{arguments}/>\n"
    else
      block ? "<#{m}#{arguments}>#{block.call}</#{m}>" : "<#{m}#{arguments}/>"
    end
  end

end