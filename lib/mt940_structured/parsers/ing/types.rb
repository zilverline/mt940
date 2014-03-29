module MT940Structured::Parsers::Ing
  module Types
    def human_readable_type(type)
      ING_MAPPING[type.strip] || type.strip
    end

    ING_MAPPING = {}
    ING_MAPPING["AC"]= "Acceptgiro"
    ING_MAPPING["BA"]= "Betaalautomaattransactie"
    ING_MAPPING["CH"]= "Cheque"
    ING_MAPPING["DV"]= "Diversen"
    ING_MAPPING["FL"]= "Filiaalboeking, concernboeking"
    ING_MAPPING["GF"]= "Telefonisch bankieren"
    ING_MAPPING["GM"]= "Geldautomaat"
    ING_MAPPING["GT"]= "Internetbankieren"
    ING_MAPPING["IC"]= "Incasso"
    ING_MAPPING["OV"]= "Overschrijving"
    ING_MAPPING["PK"]= "Opname kantoor"
    ING_MAPPING["PO"]= "Periodieke overschrijving"
    ING_MAPPING["ST"]= "ST Storting (eigen rekening of derde)"
    ING_MAPPING["VZ"]= "Verzamelbetaling"
    ING_MAPPING["Code"]= "Toelichting"
    ING_MAPPING["CHK"]= "Cheque"
    ING_MAPPING["TRF"]= "Overboeking buitenland"
  end
end
