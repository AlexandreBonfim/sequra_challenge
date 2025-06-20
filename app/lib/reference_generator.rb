class ReferenceGenerator
  def self.disbursement_reference(merchantReference)
    date = Date.current

    "DISP-#{merchantReference}-#{date.strftime('%Y%m%d')}"
  end
end
