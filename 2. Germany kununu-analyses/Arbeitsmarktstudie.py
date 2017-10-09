# -*- coding: utf-8 -*-
"""
Created on Sun May 21 08:54:09 2017

@author: Mats
"""
import bs4
import pandas as pd
import requests
import openpyxl

global str

# Wird gebraucht, um Benefit-Kennzahlen zu importieren
def Umwandeln(Kennzahl):
    Kennzahl = [int(s) for s in Kennzahl.split() if s.isdigit()]   
    if (Kennzahl == []):
        return
    else:
        Kennzahl1 = Kennzahl[0]
        Kennzahl2 = Kennzahl[1]
        Kennzahl = round((Kennzahl1 / Kennzahl2), 2)
        return(Kennzahl)
    
            
# Festlegung von Stammdaten
file = "Studien.xlsx" # Original-Excel mit Unternehmensnamen in Spalte 1
Tabellenblattname = "Studien1.xlsx" # Überlaufsventil, wo Daten importiert werden
Speicherort = "c:\\Benutzer\\Mats" # Speicherort PC

# Import von 2 Listen:
data = pd.ExcelFile(file)  
  
# Unternehmensnamen
df = data.parse("Tabelle1", parse_cols = [1])
Unternehmensliste = [df] # enthält alle Namen

# Position                    
df2 = data.parse("Tabelle1", parse_cols = [0]) 
Position = [df2] # # enthält alle Positionen

wb = openpyxl.Workbook()
ExcelName = Tabellenblattname
sheet = wb.active
sheet.title = Tabellenblattname

# Start beider for-schleifen gleichzeitig
for (i, b) in zip(Unternehmensliste, Position):
    # Panda-Data-Frame wird zu einer "Liste" transformiert
    b = b.values.tolist()
    # Wieviele Unternehmen sollten in einem Durchlauf ausgewertet werden?
    for x in range(361, 362): # Studien1 SCHLIEßEN!!!!
        # URL-Adresse wird erstellt
        adress = "https://www.kununu.com/de/" + i + ""
        adress = adress.values.tolist()
        adress = adress[x][0]
        print(adress)
        
        Zeilennummer = b[x][0]  
        
        # Jeder "Block" wertet 1 Kennzahl aus
        

         # Kununu-Scoring
        def getScore(scoreUrl):
             res = requests.get(scoreUrl)
             res.raise_for_status()
     
             soup = bs4.BeautifulSoup(res.text, "html.parser")
             elems = soup.select(".overview-value")
             return elems[0].text.strip()
     
        Score = getScore(adress)
        Score = Score.replace(",", ".")

        

         # Branche
        def getBranch(branchUrl):
             res = requests.get(branchUrl)
             res.raise_for_status()
 
             soup = bs4.BeautifulSoup(res.text, "html.parser")
             elems = soup.select(".company-profile-sub-title")
             return elems[0].text.strip()
         
 
        Branch = getBranch(adress)
        text= Branch
        Branch1 = text.partition("Branche")[2]
        Branch2 = Branch1.replace(" ", "")
        Branch2 = Branch2.replace('\n','')

        

         # Empfehlungen in %
        def getRec(recUrl):
             recUrl = recUrl + "/kommentare"
             res = requests.get(recUrl)
             res.raise_for_status()
 
             soup = bs4.BeautifulSoup(res.text, "html.parser")
             elems = soup.select(".review-recommend-value")
             return elems[0].text.strip()
         
        Reccomend = getRec(adress)
        #print(Number)

        

         # Anzahl an Bewertungen
        def getNumber(numberUrl):
             numberUrl = numberUrl + "/kommentare"
             res = requests.get(numberUrl)
             res.raise_for_status()

             soup = bs4.BeautifulSoup(res.text, "html.parser")
             elems = soup.select(".title-number")
             return elems[0].text.strip()
         
        Number = getNumber(adress)
         #print(Number)

        
        # "Echter" Name Unternehmen
        def getName(nameUrl):
            nameUrl = nameUrl + "/kommentare"
            res = requests.get(nameUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".company-name")
            return elems[0].text.strip()
        
        Name = getName(adress)
        print(Name)
        print(Zeilennummer)
        
        # Anteil flexible Arbeitszeiten
        def getWorktime(worktimeUrl):
            worktimeUrl = worktimeUrl + "/kommentare"
            res = requests.get(worktimeUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-workhours")
            return elems[0].text.strip()
        
        Worktime = getWorktime(adress)
        Worktime = Umwandeln(Worktime) 
        print(Worktime)
        
        # Anteil Home-Office
        def getHome(homeUrl):
            homeUrl = homeUrl + "/kommentare"
            res = requests.get(homeUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-homeoffice")
            return elems[0].text.strip()
        
        Home = getHome(adress)
        Home = Umwandeln(Home) 
        print(Home) 
        
        # Anteil Kantine
        def getKantine(kantineUrl):
            kantineUrl = kantineUrl + "/kommentare"
            res = requests.get(kantineUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-cafeteria")
            return elems[0].text.strip()
        
        Kantine = getKantine(adress)
        Kantine = Umwandeln(Kantine) 
        print(Kantine)        
        
         # Anteil Essenszulagen
        def getFood(foodUrl):
            foodUrl = foodUrl + "/kommentare"
            res = requests.get(foodUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-food")
            return elems[0].text.strip()
        
        Food = getFood(adress)
        Food = Umwandeln(Food) 
        print(Food)  
        
         # Anteil Kinderbetreuung
        def getKids(kidsUrl):
            kidsUrl = kidsUrl + "/kommentare"
            res = requests.get(kidsUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-childcare")
            return elems[0].text.strip()
        
        Kids = getKids(adress)
        Kids = Umwandeln(Kids) 
        print(Kids) 
        
        # Anteil betriebliche Altersvorsorge
        def getRent(rentUrl):
            rentUrl = rentUrl + "/kommentare"
            res = requests.get(rentUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-401k")
            return elems[0].text.strip()
        
        Rent = getRent(adress)
        Rent = Umwandeln(Rent) 
        print(Rent)         
        
        # Anteil Barrierefreiheit
        def getDis(disUrl):
            disUrl = disUrl + "/kommentare"
            res = requests.get(disUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-accessibility")
            return elems[0].text.strip()
        
        Dissability = getDis(adress)
        Dissability = Umwandeln(Dissability) 
        print("Barrierefreiheit:" + str(Dissability))        
        
        # Anteil Gesundheitsmaßnahmen
        def getFitness(fitUrl):
            fitUrl = fitUrl + "/kommentare"
            res = requests.get(fitUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-fitness")
            return elems[0].text.strip()
        
        Fitness = getFitness(adress)
        Fitness = Umwandeln(Fitness) 
        print(Fitness)
        
        # Anteil Betriebsarzt
        def getMedic(medUrl):
            medUrl = medUrl + "/kommentare"
            res = requests.get(medUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-medic")
            return elems[0].text.strip()
        
        Medic = getMedic(adress)
        Medic = Umwandeln(Medic) 
        print(Medic)
        
        # Anteil Coaching
        def getCoach(coachUrl):
            coachUrl = coachUrl + "/kommentare"
            res = requests.get(coachUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-coaching")
            return elems[0].text.strip()
        
        Coach = getCoach(adress)
        Coach = Umwandeln(Coach) 
        print(Coach)   
        
        # Anteil Parking
        def getParking(parkUrl):
            parkUrl = parkUrl + "/kommentare"
            res = requests.get(parkUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-parking")
            return elems[0].text.strip()
        
        Parking = getParking(adress)
        Parking = Umwandeln(Parking) 
        print(Parking)        
        
        # Anteil Verkehrsanbindung
        def getTransport(transkUrl):
            transkUrl = transkUrl + "/kommentare"
            res = requests.get(transkUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-transportation")
            return elems[0].text.strip()
        
        Transport = getTransport(adress)
        Transport = Umwandeln(Transport) 
        print(Transport)
        
        # Anteil Mitarbeiterrabatt
        def getDiscount(discUrl):
            discUrl = discUrl + "/kommentare"
            res = requests.get(discUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-discount")
            return elems[0].text.strip()
        
        Discount = getDiscount(adress)
        Discount = Umwandeln(Discount) 
        print(Discount)
        
        # Anteil Betriebswagen
        def getCar(carUrl):
            carUrl = carUrl + "/kommentare"
            res = requests.get(carUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-car")
            return elems[0].text.strip()
        
        Car = getCar(adress)
        Car = Umwandeln(Car) 
        print(Car)
        
        # Anteil Mitarbeiterhandy
        def getHandy(handyUrl):
            handyUrl = handyUrl + "/kommentare"
            res = requests.get(handyUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-phone")
            return elems[0].text.strip()
        
        Handy = getHandy(adress)
        Handy = Umwandeln(Handy) 
        print(Handy)    
        
        # Anteil Mitarbeiterbeteiligungen
        def getShares(sharesUrl):
            sharesUrl = sharesUrl + "/kommentare"
            res = requests.get(sharesUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-shares")
            return elems[0].text.strip()
        
        Shares = getShares(adress)
        Shares = Umwandeln(Shares) 
        print(Shares)   
        
        # Anteil Mitarbeiterevents
        def getEvents(eventUrl):
            eventUrl = eventUrl + "/kommentare"
            res = requests.get(eventUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-events")
            return elems[0].text.strip()
        
        Events = getShares(adress)
        Events = Umwandeln(Events) 
        print(Events)   
        
        # Anteil Internetnutzung
        def getInternet(intUrl):
            intUrl = intUrl + "/kommentare"
            res = requests.get(intUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-internet")
            return elems[0].text.strip()
        
        Internet = getInternet(adress)
        Internet = Umwandeln(Internet) 
        print(Internet)
        
        # Anteil Hunde geduldet
        def getDog(dogUrl):
            dogUrl = dogUrl + "/kommentare"
            res = requests.get(dogUrl)
            res.raise_for_status()

            soup = bs4.BeautifulSoup(res.text, "html.parser")
            elems = soup.select(".benefit-dogs")
            return elems[0].text.strip()
        
        Dog = getDog(adress)
        Dog = Umwandeln(Dog) 
        print(Dog)  
        
        
        sheet["E" + str(Zeilennummer)] = float(Score)
        sheet["G" + str(Zeilennummer)] = Branch2
        sheet["D" + str(Zeilennummer)] = Reccomend
        sheet["F" + str(Zeilennummer)] = int(Number)
        sheet["B" + str(Zeilennummer)] = Name
        sheet["M" + str(Zeilennummer)] = Worktime
        sheet["N" + str(Zeilennummer)] = Home   
        sheet["O" + str(Zeilennummer)] = Kantine                 
        sheet["P" + str(Zeilennummer)] = Food               
        sheet["Q" + str(Zeilennummer)] = Kids 
        sheet["R" + str(Zeilennummer)] = Rent        
        sheet["S" + str(Zeilennummer)] = Dissability   
        sheet["T" + str(Zeilennummer)] = Fitness
        sheet["U" + str(Zeilennummer)] = Medic   
        sheet["V" + str(Zeilennummer)] = Coach       
        sheet["W" + str(Zeilennummer)] = Parking
        sheet["X" + str(Zeilennummer)] = Transport                   
        sheet["Y" + str(Zeilennummer)] = Discount 
        sheet["Z" + str(Zeilennummer)] = Car               
        sheet["AA" + str(Zeilennummer)] = Handy   
        sheet["AB" + str(Zeilennummer)] = Shares
        sheet["AC" + str(Zeilennummer)] = Events              
        sheet["AD" + str(Zeilennummer)] = Internet 
        sheet["AE" + str(Zeilennummer)] = Dog  
              
wb.save(ExcelName)
print("Excel-Datei wurde unter " + Speicherort + " gespeichert als " + ExcelName + "")
    
