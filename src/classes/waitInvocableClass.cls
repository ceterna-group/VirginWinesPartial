/**
 * Created by lferreira036 on 18-06-2019.
 */
public class waitInvocableClass {
	@InvocableMethod(label='Invoke Apex method: wait method' description='Create a Person Account in Mantiki, if succeds create in Salesforce')
	public static void wait(/*Integer millisec*/) {
		Integer millisec = 2000;
		if(millisec == null || millisec < 0) {
			millisec = 0;
		}


		Long finishTime = DateTime.now().getTime() + millisec;
		Long actualTime = DateTime.now().getTime();
		while (finishTime > actualTime) {
			//sleep for parameter x millisecs
			actualTime = DateTime.now().getTime();
		}
		System.debug('>>> actualTime ' + actualTime + ' finishTime ' + finishTime);
	}
}