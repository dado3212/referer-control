#import <objc/runtime.h>

NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.referercontrol.plist";

static NSString *getNewReferer(NSString *url, NSArray *referers) {
  for (NSArray *referer in referers) {
    NSError *error = nil;
    if ([referer count] == 3 && [referer[0] boolValue]) { // Standard format and enabled
      NSString *regex;
      // Escape regex characters, convert * to .*
      NSRegularExpression *replace = [NSRegularExpression regularExpressionWithPattern:@"([\\.\\^\\$\\*\\+\\?\\(\\)\\[\\{\\\\|])" options:0 error:&error];
      regex = [replace stringByReplacingMatchesInString:referer[1] options:0 range:NSMakeRange(0, [referer[1] length]) withTemplate:@"\\\\$1"];
      regex = [regex stringByReplacingOccurrencesOfString:@"\\*" withString:@".*"];

      NSRegularExpression* test = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];

      if (error == nil) {
        NSUInteger numberOfMatches = [test numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])];

        if (numberOfMatches > 0) {
          return referer[2];
        }
      }
    }
  }
  return nil;
}

%hook WKNavigationAction
-(NSURLRequest *)request {
  NSURLRequest *request = %orig;

  // Check if it matches the preferences
  NSArray *referers = [[NSArray alloc] initWithContentsOfFile:prefPath];

  NSString *newReferer = getNewReferer([[request URL] absoluteString], referers);

  if (newReferer != nil) {
    // Add the preferences request header
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setValue:newReferer forHTTPHeaderField:@"Referer"];
    // Has to be set for the referer to work on chrome...
    [mutableRequest setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0 Mobile/14C92 Safari/602.1" forHTTPHeaderField:@"User-Agent"];
    NSLog(@"evaluating request: %@ (yup)", [[request URL] host]);
    return [mutableRequest copy];
  } else {
    NSLog(@"evaluating request: %@ (no)", [[request URL] host]);
    return request;
  }
}
%end