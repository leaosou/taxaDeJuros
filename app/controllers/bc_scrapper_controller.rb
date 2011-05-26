class BcScrapperController < ApplicationController
    def initialize
      require 'rubygems'
      require 'mechanize'
      
      @msg = Time.now
  
      agent = Mechanize.new
  
      url  = "http://www.bcb.gov.br/fis/taxas/htms/tx012010.asp"
      page = agent.get(url)
  
      #this array holds all the banks that are in the scraped web page
      @vetorInst = Array.new()
      
      #this array holds all the lines to generate the flare.js used by Protovis
      @vetorFlareJS = Array.new()
      
      #scrap the web page
      page.at("//table[2]").search('tr[@class="fundoPadraoBClaro1 centralizado"]').each do |item|
  
        inst = Hash.new
  
        inst['institution'] = item.children[2].text
        inst['value'] = item.children[3].text
  
        @vetorInst << inst
      end   
      
      #generate the flare.js into the array
      @vetorFlareJS = generateFlareJavaScript   
      
      File.open('public/javascripts/flare.js', 'w') {
        |f| f.write(@vetorFlareJS) 
      }

=begin
      File.new('public/javascripts/flare.js', 'w') do |f|
        @vetorFlareJS.each do |item|
          f.write item.txt
          f.puts
        end
      end
=end

    end
    
    #private
    def correctBankName(aString)
      aString.slice!('BCO DO ')
      aString.slice!('BCO ')
      aString.slice!('BANCO ')
      aString.slice!(' (BRASIL)')
      aString.slice!(' S.A')
      aString.slice!(' S A')
      aString.slice!(' S.A.')
      aString.slice!(' SA')
      aString.slice!(' S.A')
      
      #substitute spaces by underscore
      aString.gsub!(" ","_")
      #remove dot, if any, at the string's end
      if (aString[-1,1] == '.') then
        aString = aString[0, aString.length-1]
      end
      return aString
    end

    private
    def correctValue(aString)
      #Remove decimal comma & Multiply by 10000
      pos = aString.index(",")
      aString = aString[0..pos-1] + aString[pos+1..aString.length] + "0,"
      return aString
    end
    
    private
    def generateFlareJavaScript

        numBanks = @vetorInst.length
        if (numBanks < 2) then
          puts("vetor institutions was not filled")
          return
        end
        groupSize = numBanks / 3
        if ((numBanks % 3) != 0) then
        groupSize+=1
        end
    
        numGroup = 0
        countLine = 0
    
        #First header group
        @vetorFlareJS << "var flare = {\n" +
              "  analytics: {\n" +
              "    menor: {\n"
    
        @vetorInst.each do |inst|
          if (countLine == groupSize) then
            countLine = 0
            numGroup+=1
            if (numGroup == 1) then
              #Second header group
              @vetorFlareJS <<
               "    },\n" +
               "    medio: {\n"
            else
            #Third header group
              @vetorFlareJS <<
               "    },\n" +
               "    maior: {\n"
            end
          end
          @vetorFlareJS << '        ' + correctBankName(inst['institution']) +
                          ': ' + correctValue(inst['value'])
          countLine+=1
        end
    
        #Trailing group
        @vetorFlareJS <<
              "    }\n" +
              "  }\n\n" +
              "};"
    end


  def pf_cheque_especial

  end

  def proto

  end
  
end
