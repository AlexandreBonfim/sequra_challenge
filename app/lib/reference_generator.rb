class ReferenceGenerator
  def self.disbursement_reference(merchant)
    date = Date.current

    "DISP-#{merchant.reference}-#{date.strftime('%Y%m%d')}"
  end
end
