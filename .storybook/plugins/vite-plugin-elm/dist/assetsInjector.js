"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.injectAssets = void 0;
const acorn_1 = require("acorn");
const acorn_walk_1 = require("acorn-walk");
const crypto_1 = __importDefault(require("crypto"));
const ASSET_TAG = /'\[VITE_PLUGIN_ELM_ASSET:(?<path>.+?)\]'/g;
const HELPER_PACKAGE_IDENTIFIER = 'VITE_PLUGIN_HELPER_ASSET';
const importNameFrom = (path) => {
    return '_' + crypto_1.default.createHash('sha1').update(path).digest('hex');
};
const generateImports = (paths) => {
    return paths.map((path) => `import ${importNameFrom(path)} from '${path}'`).join('\n');
};
const isLiteral = (node) => node.type === 'Literal';
const isDeclarator = (node) => node.type === 'VariableDeclarator';
const isCallExpression = (node) => node.type === 'CallExpression';
const injectAssets = (compiledESM) => {
    const taggedPaths = [];
    const ast = (0, acorn_1.parse)(compiledESM, { ecmaVersion: 2015, sourceType: 'module' });
    let helperFunctionName;
    (0, acorn_walk_1.fullAncestor)(ast, (node, state) => {
        var _a, _b;
        if (isLiteral(node)) {
            // Find callers of VitePluginHelper.asset
            if (!helperFunctionName && node.raw === `'${HELPER_PACKAGE_IDENTIFIER}'`) {
                const helperFunc = state === null || state === void 0 ? void 0 : state.find((nodeOnState) => {
                    var _a, _b, _c, _d, _e, _f;
                    return isDeclarator(nodeOnState) &&
                        ((_f = (_e = (_d = (_c = (_b = (_a = nodeOnState === null || nodeOnState === void 0 ? void 0 : nodeOnState.init) === null || _a === void 0 ? void 0 : _a.body) === null || _b === void 0 ? void 0 : _b.body) === null || _c === void 0 ? void 0 : _c[0]) === null || _d === void 0 ? void 0 : _d.argument) === null || _e === void 0 ? void 0 : _e.left) === null || _f === void 0 ? void 0 : _f.raw) === `'${HELPER_PACKAGE_IDENTIFIER}'`;
                });
                if ((_a = helperFunc === null || helperFunc === void 0 ? void 0 : helperFunc.id) === null || _a === void 0 ? void 0 : _a.name) {
                    helperFunctionName = helperFunc.id.name;
                    (0, acorn_walk_1.fullAncestor)(ast, (node) => {
                        var _a, _b;
                        if (isCallExpression(node) && ((_a = node === null || node === void 0 ? void 0 : node.callee) === null || _a === void 0 ? void 0 : _a.name) === helperFunctionName) {
                            if (((_b = node === null || node === void 0 ? void 0 : node.arguments) === null || _b === void 0 ? void 0 : _b.length) === 1 && isLiteral(node.arguments[0])) {
                                const matchedPath = node.arguments[0].value;
                                taggedPaths.push({
                                    path: matchedPath,
                                    start: node.start,
                                    end: node.end,
                                });
                            }
                            else {
                                throw 'Arguments for VitePluginHelper should be just a plain String';
                            }
                        }
                    }, undefined, null);
                }
                return;
            }
            // Find plain asset tags
            const matched = ASSET_TAG.exec(node.raw);
            if (matched !== null) {
                if ((_b = matched.groups) === null || _b === void 0 ? void 0 : _b.path) {
                    taggedPaths.push({
                        path: matched.groups.path,
                        start: node.start,
                        end: node.end,
                    });
                }
            }
        }
    }, undefined, null);
    if (taggedPaths.length > 0) {
        const src = compiledESM.split('');
        const importPaths = [];
        taggedPaths.forEach(({ path, start, end }) => {
            for (let i = start; i < end; i++) {
                src[i] = '';
            }
            src[start] = importNameFrom(path);
            if (!importPaths.includes(path)) {
                importPaths.push(path);
            }
        });
        return `${generateImports(importPaths)}\n\n${src.join('')}`;
    }
    else {
        return compiledESM;
    }
};
exports.injectAssets = injectAssets;
//# sourceMappingURL=assetsInjector.js.map