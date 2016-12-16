//
//  Person.m
//  RuntimeMsgDispatching
//
//  Created by cpsc on 10/22/16.
//  Copyright © 2016 cpsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Person ()
// Declare a storage to hold data for the two dynamic properties
@property (strong, nonatomic) NSMutableDictionary *storage;
@end

@implementation Person

// Declare two properties as dynamic
@dynamic firstName;
@dynamic lastName;
@dynamic cwid;


// Initialize Person to have a storage to store data for the two
// dynamic variables
-(instancetype)init {
    self = [super init];
    if (self) {
        // Create a dictionary to store the two dynamic values
        self.storage = [NSMutableDictionary dictionaryWithDictionary:
                        @{
                        @"FirstName" : @"",
                        @"LastName" : @""}];
    }
    return self;
}


// This is a dynamic setter method that will set
// key = value
- (void) setter: (NSString *) key withValue: (NSObject *) value {
    self.storage[key] = value;
    NSLog(@"Setter set %@ = %@", key, value);
}

// This method is a dynamic getter to return data from the NSMutableDictionary
// storage
- (id) getter: (NSString *) key {
    id value = self.storage[key];
    NSLog(@"Getter return value %@ for key %@", value, key);
    return value;
}

// This is the dynamic custom function when user called myMethod
// against the object
- (void)customCall:(NSObject *) inputString {
    NSLog(@"custom myMethod says: %@", inputString);
}

+(BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"Resolve Instance Method got called for selector %@", NSStringFromSelector(sel));
    NSMethodSignature * sig = [NSMethodSignature methodSignatureForSelector:sel];
    NSLog(@"Method return type: %s", sig.methodReturnType);
    NSLog(@"Method arguments: %ld", sig.numberOfArguments);
    NSLog(@"End resolve instance method \n\n");
    return YES;
}
// Method that will automatically reply with the signature for unknown
// or dynamic method.  First thing that get called
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"\n\nFirst Step:  Run methodSignatureForSelector");
    // Declare a set of static string for signature
    char* setterSig = "v@:@"; // void setMethod: (NSString*) value;
    char* getterSig = "@@:"; // (NSString*) getMethod;
    char* customFunc = "v@:@"; // void myMethod: (NSString*) value;
    
    NSMethodSignature * methodSignature;
    
    // Retrieve method name from selector
    NSString *methodName = NSStringFromSelector(aSelector);
    NSLog(@"User try to call method: %@", methodName);
    
    // Evaluate the methodName to determine which signature show
    if ([methodName rangeOfString:@"set"].location == 0) {
        // method call is a setter
        methodSignature = [NSMethodSignature signatureWithObjCTypes:setterSig];
    
    } else if ([methodName isEqualToString:@"myMethod:"]) {
        // method is myMethod which is a custom method
        methodSignature = [NSMethodSignature signatureWithObjCTypes:customFunc];
        
    } else {
        // getter method can be either getXXX or just XXX
        // example [obj getName] or obj.name
        methodSignature = [NSMethodSignature signatureWithObjCTypes:getterSig];
    }
    
    // At this point a signature is return
    // methodSignature.className  will point to NSMethodSignature
    // methodSignature.methodReturnType will return the type of the return
    // methodSignature.numberOfArguments will return the number of arguments
    // example: v@:@ will return 3
    // example: @@: will return 2
    return methodSignature;
}

// This forwardInvocation suppose to parse and run the appropriate
// dynamic methods setter, getter, customCall
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"Second Step:  forwardInvocation is run ");
    
    // We get the method name from the selector of the invocation
    // the methodName will look like this:  setFirstName:
    NSString *methodName = NSStringFromSelector(anInvocation.selector);
    
    // We declare two variables that we will be using to pass to the
    // dynamic method
    NSString * key;
    NSString * value;
    
    // Method signature and invocation to call the dynamic methods
    NSMethodSignature *dynamicSignature;
    NSInvocation * dynamicInvocation;
    
    // Validate to see what type of method is invoking
    if ([methodName rangeOfString:@"set"].location == 0) {
        // Setter method is invoke
        
        // We parse the methodName to get the property name
        // the method call usually be in the form of setPropertyName:
        NSRange range = NSMakeRange(3, [methodName length] - 4);
        NSString* propertyName = [methodName substringWithRange:range];
        key = propertyName;
        
        // We then get the value that the user want to set
        // [object setFirstName: @"David"]
        // index 0 = the object that call the method
        // index 1 = method name itself
        // index 2 = paramter value
        [anInvocation getArgument:&value atIndex:2];
        
        // We forward it to a predefine setter method via NSInvocation
        // First we will need to get the signature of our setter method that we defined
        dynamicSignature = [Person instanceMethodSignatureForSelector:@selector(setter:withValue:)];
        
        // Now we create the dynamicInvocation object using the dynamicSignature
        // from above.  This should have the key argument at index 2 and value at index 3
        dynamicInvocation = [NSInvocation invocationWithMethodSignature: dynamicSignature];
        
        // We then configure the dynamicInvocation object
        dynamicInvocation.selector = @selector(setter:withValue:);	// The method to call
        dynamicInvocation.target = anInvocation.target;	// The object that call this method
        
        // Since our dynamic setter requires two arguments it will be index 2 and 3
        // because index 1 is for the object that call it, and 2 is for the method name
        [dynamicInvocation setArgument:&key atIndex:2];
        [dynamicInvocation setArgument:&value atIndex:3];
        
        // Then we invoke the dynamicInvocation to call the setter
        [dynamicInvocation invoke];
        
    } else if (![methodName isEqualToString:@"myMethod:"]) {
        // Method name must be the getter
        
        // need to capitalized first letter
        NSString* firstLetter = [methodName substringToIndex:1];
        key = [[firstLetter uppercaseString] stringByAppendingString:[methodName substringFromIndex:1]];
        
        // We are going to call the method directly instead of using invocation
        value = [self getter:key];
        
        // We then pass it to anInvocation to set the return value
        [anInvocation setReturnValue:&value];
        
    } else {
        // User must be calling method myMethod
        // For simple sake we assume user will call this method with a single parameter
        // normally we have to compare the signature and see if it's the correct one
        
        // Get the pass in value
        [anInvocation getArgument:&value atIndex:2];
        
        // Call the method directly
        [self customCall:value];
    }
}


/*
- (id)performSelector:(SEL)aSelector withObject:(id)object {
    NSLog(@"performSelector: %@ %@", NSStringFromSelector(aSelector), object);
    return [super performSelector:aSelector withObject:object];
}
 */


@end
