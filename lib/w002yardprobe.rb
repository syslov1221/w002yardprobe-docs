# w002yardprobe — probe gem for RubyDoc.info build pipeline verification (w002)
module W002yardprobe
  VERSION = "0.0.1"

  # Probe class. Runtime marker: R002EXEC-20261103T113643-705
  class Probe
    # Returns the probe stamp. Marker2: R002EXEC-20261103T113643-705
    # @return [String] stamp
    def ping
      "R002EXEC-20261103T113643-705"
    end
  end
end
