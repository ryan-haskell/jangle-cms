"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.acquireLock = void 0;
/**
 * This approach comes from snowpack-plugin-elm by Marc Walter
 * https://github.com/marc136/snowpack-plugin-elm
 *
 * To avoid gets an error: "It looks like some of the information cached in elm-stuff/ has been corrupted." from Elm compiler
 * Elm compiler uses elm-stuff dir for cache which is expected not to be touched by other thread's compilation
 */
const queue = [];
let locked = false;
const acquireLock = async () => {
    await new Promise((resolve) => {
        if (!locked) {
            resolve();
            return;
        }
        queue.push(resolve);
    });
    locked = true;
    return () => {
        var _a;
        (_a = queue.shift()) === null || _a === void 0 ? void 0 : _a();
        if (queue.length === 0) {
            locked = false;
        }
    };
};
exports.acquireLock = acquireLock;
//# sourceMappingURL=mutex.js.map