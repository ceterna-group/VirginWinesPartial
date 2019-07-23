public with sharing class IndividualTriggerHandler {
    /** @description Before Update 
    * @param Individual (new and old)
    * @return void
    * @date 2019  **/  
    public static void AfterUpdateHandle(List<Individual> listNewIndividual, List<Individual> listOldIndividual, Map<Id, Individual> mapOldIndividual) {
    	Map<Id,Individual> mapListInd = new Map<Id,Individual>();
    	for(Individual ind : listNewIndividual){
			if(ind.Other_Third_Parties_Email__c != mapOldIndividual.get(ind.Id).Other_Third_Parties_Email__c ||
				ind.Other_Virgin_Companies_Email__c != mapOldIndividual.get(ind.Id).Other_Virgin_Companies_Email__c ||
				ind.Daily_Mail_emails__c != mapOldIndividual.get(ind.Id).Daily_Mail_emails__c ||
				ind.Virgin_Wines_emails__c != mapOldIndividual.get(ind.Id).Virgin_Wines_emails__c ||
                ind.Daily_Mail_Other_Phone__c != mapOldIndividual.get(ind.Id).Daily_Mail_Other_Phone__c   ||
                ind.Daily_Mail_Other_Post__c != mapOldIndividual.get(ind.Id).Daily_Mail_Other_Post__c ||
                ind.Daily_Mail_Other_SMS__c != mapOldIndividual.get(ind.Id).Daily_Mail_Other_SMS__c ||
                ind.Virgin_Wines_other_Phone__c != mapOldIndividual.get(ind.Id).Virgin_Wines_other_Phone__c ||
                ind.Virgin_Wines_other_Post__c != mapOldIndividual.get(ind.Id).Virgin_Wines_other_Post__c ||
                ind.Virgin_Wines_other_SMS__c != mapOldIndividual.get(ind.Id).Virgin_Wines_other_SMS__c ||
                ind.Send_a_Gift_emails__c != mapOldIndividual.get(ind.Id).Send_a_Gift_emails__c ||
                ind.Send_a_Gift_other_Phone__c != mapOldIndividual.get(ind.Id).Send_a_Gift_other_Phone__c ||
                ind.Send_a_Gift_other_Post__c != mapOldIndividual.get(ind.Id).Send_a_Gift_other_Post__c ||
                ind.Send_a_Gift_other_SMS__c != mapOldIndividual.get(ind.Id).Send_a_Gift_other_SMS__c    ||
                ind.Wine_Advisor_emails__c != mapOldIndividual.get(ind.Id).Wine_Advisor_emails__c)	{
				mapListInd.put(ind.Id,ind);
			}
    	}
    	if(mapListInd.size()>0)	{
    		for(Individual ind : listNewIndividual){
    			if(mapListInd.containsKey(ind.Id))	{
    				serializeIndividual(JSON.serialize(mapListInd.get(ind.Id)));
    			}
    		}
    		
    	}
    }  
    
    @future(callout=true)
    public static void serializeIndividual(String ind)   {
    	Individual tempIndividual = (Individual) JSON.deserialize(ind, Individual.class);
    	List<Individual> individualList = [SELECT Customer_ID__c, Contact__r.Account.AccountNumber, Contact__r.Account.Store__c
    	                                    FROM Individual where id = :tempIndividual.Id LIMIT 1];
        CalloutsClass.individualUpdate(ind,individualList[0].Customer_ID__c,individualList[0].Contact__r.Account.Store__c);
    }
}