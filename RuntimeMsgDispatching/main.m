//
//  main.m
//  RuntimeMsgDispatching
//
//  Created by cpsc on 10/22/16.
//  Copyright © 2016 cpsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
		
        // Create a Person object
        Person * newPerson = [[Person alloc] init];
        
        // Set the firstName of the Person.  This should trigger
        // the dynamic invocation
        newPerson.firstName = @"David";
        
        // This will trigger a call to a getter to get the name back
        NSString * name = newPerson.firstName;
        
        // Test to see if we can get the name using get
       	[newPerson setLastName:@"Dang"];
        NSString *last = [newPerson lastName];
        
        newPerson.cwid = @123456;
        
        NSLog(@"\n\nFirst Name returned: %@", name);
        NSLog(@"Last Name returned: %@", last);
	
        // Call a custom method called myMethod
        //[newPerson performSelector:NSSelectorFromString(@"myMethod:") withObject: @"Hello Dynamic Dispatching"];
        [newPerson performSelector:@selector(myMethod:) withObject: @"Hello Dynamic Dispatching"];
        
        NSLog(@"Class Name is: %@", [newPerson className]);
        
    }
    return 0;
}
