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
        inst['abrevName'] = correctBankName(item.children[2].text)
        @vetorInst << inst
      end   
      
      #generate the flare.js into the array
      @vetorFlareJS = generateFlareJavaScript   
      
      File.open('public/javascripts/flare.js', 'w') {
        |f| f.write(@vetorFlareJS) 
      }

    end

    private
    def correctBankName(aString)
      strigToCorrect = aString
      strigToCorrect.slice!('BCO DO ')
      strigToCorrect.slice!('BCO ')
      strigToCorrect.slice!('BANCO ')
      strigToCorrect.slice!(' (BRASIL)')     
      strigToCorrect.slice!(' S.A')
      strigToCorrect.slice!(' S A')
      strigToCorrect.slice!(' S.A.')
      strigToCorrect.slice!(' SA')
      strigToCorrect.slice!(' S.A')
      
      #substitute double spaces by single space
      strigToCorrect.squeeze!(" ")
      #substitute spaces by underscore
      strigToCorrect.gsub!(" ","_")
      
      #remove EST_DO_  and  EST_DE_  DA_  LA_
      strigToCorrect.slice!('EST_DO_') 
      strigToCorrect.slice!('EST_DE_') 
      strigToCorrect.slice!('DA_') 
      strigToCorrect.slice!('LA_')
      #remove dot, if any, at the string's end
      if (strigToCorrect[-1,1] == '.') then
        strigToCorrect = strigToCorrect[0, strigToCorrect.length-1]
      end
      return strigToCorrect
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
          @vetorFlareJS << '        ' + inst['abrevName'] +
                          ': ' + correctValue(inst['value']) + "\n"
          countLine+=1
        end
    
        #Trailing group
        @vetorFlareJS <<
              "    }\n" +
              "  }\n\n" +
              "};\n"
    end


  def pf_cheque_especial

  end

  def proto

  end
  
end
