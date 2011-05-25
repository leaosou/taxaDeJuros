class BcScrapperController < ApplicationController
  def pf_cheque_especial
    require 'rubygems'
    require 'mechanize'
    #gem 'mechanize'
    
    @msg = Time.now

    agent = Mechanize.new

    url  = "http://www.bcb.gov.br/fis/taxas/htms/tx012010.asp"
    page = agent.get(url)
    #@pg = "";
    @vetorInst = Array.new()
    
    page.at("//table[2]").search('tr[@class="fundoPadraoBClaro1 centralizado"]').each do |item|

      inst = Hash.new

      inst['instituicao'] = item.children[2].text
      inst['valor'] = item.children[3].text

      @vetorInst << inst
    end

    #@vetorInst.each do |item|
    #  # @pg = @pg + 'banco: ' + item['instituicao'] + ' valor: ' + item['valor'] + '<br>'
    #end

  end

  def proto
  end
  
end
