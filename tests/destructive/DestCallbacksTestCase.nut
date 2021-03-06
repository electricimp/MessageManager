// MIT License
//
// Copyright 2017 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// "Promise" symbol is injected dependency from ImpUnit_Promise module,
// while class being tested can be accessed from global scope as "::Promise".

@include __PATH__+"/BaseDestructive.nut"

// DestCallbacksTestCase
// Destructive tests for MessageManager.onFail MessageManager.onTimeout, MessageManager.onAck, MessageManager.onReply
class DestCallbacksTestCase extends BaseDestructive {

    function setUp() {
        infoAboutSide();
    }

    function testOnFailWithReturn() {
        local execute = function(value) {
            return Promise(function(resolve, reject) {
                try {
                    local mm = MessageManager({
                        "firstMessageId":  msgId,
                        "nextIdGenerator": msgIdGenerator
                    });
                    mm.beforeSend(function(msg, enqueue, drop) {
                        drop(false);
                    }.bindenv(this));
                    mm.onFail(function(msg, reason, retry) {
                        imp.wakeup(0.5, resolve);
                        return value;
                    }.bindenv(this));
                    mm.send(MESSAGE_NAME, BASIC_MESSAGE);
                } catch (ex) {
                    reject("Catch: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this);
        return createTestAll(execute, DEST_OPTIONS.ALL_TYPES, "positive");
    }

    function testOnFailRetryWrongParams() {
        local execute = function(value) {
            return Promise(function(resolve, reject) {
                local mm = MessageManager({
                    "firstMessageId":  msgId,
                    "nextIdGenerator": msgIdGenerator,
                    "retryInterval":   0
                });
                mm.beforeSend(function(msg, enqueue, drop) {
                    drop(false);
                }.bindenv(this));
                mm.onFail(function(msg, reason, retry) {
                    try {
                        imp.wakeup(0.5, resolve);
                        retry(value);
                    } catch (ex) {
                        reject("Catch onFail.retry: " + ex);
                    }
                }.bindenv(this));
                mm.send(MESSAGE_NAME, BASIC_MESSAGE);
            }.bindenv(this));
        }.bindenv(this);
        return createTestAll(execute, DEST_OPTIONS.WO_CONCATENATION, "negative");
    }
    
    function testOnTimeoutWithReturn() {
        local execute = function(value) {
            return Promise(function(resolve, reject) {
                try {
                    local mm = MessageManager({
                        "firstMessageId":  msgId,
                        "nextIdGenerator": msgIdGenerator,
                        "messageTimeout":  0
                    });
                    mm.onTimeout(function(msg, wait, fail) {
                        imp.wakeup(0.5, resolve);
                        return value;
                    }.bindenv(this));
                    mm.send(MESSAGE_WITH_SHORT_DELAY, BASIC_MESSAGE);
                } catch (ex) {
                    reject("Catch: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this);
        return createTestAll(execute, DEST_OPTIONS.ALL_TYPES, "positive");
    }

    function testOnTimeoutWaitWrongParams() {
        local execute = function(value) {
            return Promise(function(resolve, reject) {
                local mm = MessageManager({
                    "firstMessageId":  msgId,
                    "nextIdGenerator": msgIdGenerator,
                    "messageTimeout":  0
                });
                mm.onTimeout(function(msg, wait, fail) {
                    try {
                        imp.wakeup(0.5, resolve);
                        wait(value);
                    } catch (ex) {
                        reject("Catch onTimeout.wait: " + ex);
                    }
                }.bindenv(this));
                mm.onFail(function(msg, reason, retry) {
                    try {
                        assertDeepEqualWrap(2, counter, "Only second message should be failed");
                        resolve();
                    } catch (ex) {
                        reject(ex);
                    }
                }.bindenv(this));
                mm.send(MESSAGE_WITH_SHORT_DELAY, BASIC_MESSAGE);
            }.bindenv(this));
        }.bindenv(this);
        return createTestAll(execute, DEST_OPTIONS.WO_CONCATENATION, "negative");
    }

    function testOnAckWithReturn() {
        local execute = function(value) {
            return Promise(function(resolve, reject) {
                try {
                    local mm = MessageManager({
                        "firstMessageId":  msgId,
                        "nextIdGenerator": msgIdGenerator
                    });
                    mm.onAck(function(msg) {
                        imp.wakeup(0.5, resolve);
                        return value;
                    }.bindenv(this));
                    mm.send(MESSAGE_NAME, BASIC_MESSAGE);
                } catch (ex) {
                    reject("Catch: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this);
        return createTestAll(execute, DEST_OPTIONS.ALL_TYPES, "positive");
    }

    function testOnReplyWithReturn() {
        local execute = function(value) {
            return Promise(function(resolve, reject) {
                try {
                    local mm = MessageManager({
                        "firstMessageId":  msgId,
                        "nextIdGenerator": msgIdGenerator
                    });
                    mm.onReply(function(msg, response) {
                        imp.wakeup(0.5, resolve);
                        return value;
                    }.bindenv(this));
                    mm.send(MESSAGE_NAME, BASIC_MESSAGE);
                } catch (ex) {
                    reject("Catch: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this);
        return createTestAll(execute, DEST_OPTIONS.ALL_TYPES, "positive");
    }
}
