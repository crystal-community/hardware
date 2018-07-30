# Parse stat initialized at `Hadware::PID#stat`
struct Hardware::PID::Stat
  @stat = Array(String).new

  def initialize(@stat)
  end

  # Returns the "comm" field of `#stat`.
  def comm : String
    @stat[1]
  end

  # Returns the "state" field of `#stat`.
  def state : String
    @stat[2][1..-2]
  end

  # Generate methods based on stat
  {% begin %}{% i = 3 %}
    {% for num in %w(
                    ppid
                    pgrp
                    session
                    tty_nr
                    tpgid
                    flags minflt
                    cminflt
                    majflt
                    cmajflt
                    utime
                    stime
                    cutime
                    cstime
                    priority
                    nice
                    numthreads
                    itrealvalue
                    starttime
                    vsize
                    rss) %}
      # Returns the "{{num.id}}" field of `#stat`.
      def {{num.id}} : Int32
        @stat[{{i}}].to_i
      end
      {% i = i + 1 %}
    {% end %}{% end %}
end
