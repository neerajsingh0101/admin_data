class Car
  
  private

  def honk
    puts 'beep beep'
  end

end


c = Car.new

c.send(:honk)

c.method(:honk).call

c.instance_eval { honk }

class << c
  public :honk
end
c.honk
class << c
  private :honk
end

