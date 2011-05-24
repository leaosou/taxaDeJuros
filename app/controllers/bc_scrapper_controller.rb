class BcScrapperController < ApplicationController
  def pf_cheque_especial
    require 'mechanize'
    @msg = Time.now

    agent = WWW::Mechanize.new

    url  = "http://www.bcb.gov.br/fis/taxas/htms/tx012010.asp"
    page = agent.get(url)
    @pg = "";

    vetor = Array.new()
    page.at("//table[2]").search('tr[@class="fundoPadraoBClaro1 centralizado"]').each do |item|

      inst = Hash.new

      inst['instituicao'] = item.children[2].text
      inst['valor'] = item.children[3].text

      vetor << inst
    end

    vetor.each do |item|
      @pg = @pg + 'banco: ' + item['instituicao'] + ' valor: ' + item['valor'] + '<br>'
    end

  end


end
