'''
A cut-down gear.py for the tools' tests, in the shape of wsdist's.
'''
all_jobs = ["war", "rdm", "blu"]

Naegling = {"Name":"Naegling", "Skill Type":"Sword", "Type":"Weapon", "DMG":166, "Delay":240, "Accuracy":40, "Jobs":["rdm", "blu"]}
Nyame_Helm0 = {"Name":"Nyame Helm", "Name2":"Nyame Helm R0", "Rank":0, "Accuracy":40, "Attack":30, "Magic Attack":30, "Jobs":all_jobs}
Nyame_Helm15B = {"Name":"Nyame Helm", "Name2":"Nyame Helm R15B", "Rank":15, "Accuracy":40, "Attack":30+20, "Ranged Attack":20, "Magic Attack":30, "Weapon Skill Damage":7, "Jobs":all_jobs}
Nyame_Helm15C = {"Name":"Nyame Helm", "Name2":"Nyame Helm R15C", "Rank":15, "Accuracy":40, "Attack":30, "Magic Attack":30+20, "INT":5, "MND":5, "CHR":5, "Jobs":all_jobs}
ranged.append({"Name":"Linos", "Name2":"Linos STP QA", "Type":"Instrument", "Jobs":["brd"]})
