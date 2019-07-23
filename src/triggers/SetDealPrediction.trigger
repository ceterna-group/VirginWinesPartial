trigger SetDealPrediction on Account (after insert, after update) {
   if(System.isFuture()) return;
   if(ed_insights.CheckRecursive.runOnce()) {
   // custom Settings' name
   String CONFIG_NAME = 'Einstein Discovery';
   ed_insights.TriggerHandler.insertUpdateHandle(CONFIG_NAME);
  }
}