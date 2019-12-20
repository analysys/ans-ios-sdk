//
//  ANSAllBuryPointModel.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ANSAllBuryPointModel : ANSBaseModel
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *element_id;
@property (nonatomic, copy) NSString *element_type;
@property (nonatomic, copy) NSString *element_path;
@property (nonatomic, copy) NSString *element_content;
@property (nonatomic, copy) NSString *element_position;
@end

NS_ASSUME_NONNULL_END
