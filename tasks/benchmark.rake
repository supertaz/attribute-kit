require 'set'

def timeit(name = "", n = 1, multiplier = 1, divide = false)
  t = Time.now
  yield
  delta = Time.now - t
  delta /= n if divide
  delta *= multiplier
  puts "%15s: %2.4f" % [name, delta]
end

def stress(name, n)
  timeit(name) do
    n.times do
      yield n
    end
  end
end

def stress2(name, n, options = {})
  timeit(name, n, options[:multiplier], options[:divide]) do
    options[:before] if options[:before]
    n.times do
      options[:each][n]
    end
    options[:after] if options[:after]
  end
end

class Stresser

  def initialize(name, n, m, divide)
    @options = {
        :divide => divide,
        :multiplier => m
    }
    @name = name
    @n = n
  end

  def before(&block)
    @options[:before] = block
  end

  def each(&block)
    @options[:each] = block
  end

  def after(&block)
    @options[:after] = block
  end

  def run
    stress2(@name, @n, @options)
  end
end

def stress3(name, n, m = 1, divide = false, &block)
  o = Stresser.new(name, n, m, divide)
  o.instance_eval(&block)
  o.run
end

namespace :benchmark do

  task :run => [:insertion]

  desc "run insertion benchmarks"
  task :insertion do
    n = 10000

    stress("Set", n) do |i|
      h = Set.new
      s = "hello#{i}"
      h << s
    end

    stress("Array", n) do |i|
      h = []
      s = "hello#{i}"
      h << s
    end

    stress("Hash", n) do |i|
      h = {}
      s = "hello#{i}"
      h[s] = s
    end
  end

  desc "run insertion benchmarks"
  task :append_uniq do

    [100, 1000, 10000, 100000, 1000000].each { |n|

      p n

      GC.disable

      h = Set.new
      stress3("Set", n, 1000000, true) do
        each do |i|
          s = "hello#{i}"
          h << s
        end
      end

      h = []
      stress3("Array", n, 1000000, true) do
        each do |i|
          s = "hello#{i}"
          h << s
        end
        after do
          h.uniq!
        end
      end

      h = []
      stress3("UArray", n, 1000000, true) do
        each do |i|
          s = "hello#{i}"
          h << s
          h.uniq!
        end
      end

      h = {}
      stress3("Hash", n, 1000000, true) do
        each do |i|
          s = "hello#{i}"
          h[:foo] = s
        end
      end

      GC.enable
      GC.start

    }

  end

end


desc "run all benchmarks"
task :benchmark => ['benchmark:run']
