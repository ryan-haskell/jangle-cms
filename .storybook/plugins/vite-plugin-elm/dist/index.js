"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.plugin = void 0;
/* eslint-disable @typescript-eslint/ban-ts-comment */
//@ts-ignore
const elm_esm_1 = require("elm-esm");
//@ts-ignore
const node_elm_compiler_1 = __importDefault(require("node-elm-compiler"));
const path_1 = require("path");
const find_up_1 = __importDefault(require("find-up"));
const assetsInjector_1 = require("./assetsInjector");
const hmrInjector_1 = require("./hmrInjector");
const mutex_1 = require("./mutex");
/* eslint-enable @typescript-eslint/ban-ts-comment */
const trimDebugMessage = (code) => code.replace(/(console\.warn\('Compiled in DEBUG mode)/, '// $1');
const viteProjectPath = (dependency) => `/${(0, path_1.relative)(process.cwd(), dependency)}`;
const parseImportId = (id) => {
    const parsedId = new URL(id, 'file://');
    const pathname = parsedId.pathname;
    const valid = pathname.endsWith('.elm') && !parsedId.searchParams.has('raw');
    const withParams = parsedId.searchParams.getAll('with');
    return {
        valid,
        pathname,
        withParams,
    };
};
const findClosestElmJson = async (pathname) => {
    const elmJson = await (0, find_up_1.default)('elm.json', { cwd: (0, path_1.dirname)(pathname) });
    return elmJson ? (0, path_1.dirname)(elmJson) : undefined;
};
const plugin = (opts) => {
    var _a;
    const compilableFiles = new Map();
    const debug = opts === null || opts === void 0 ? void 0 : opts.debug;
    const optimize = opts === null || opts === void 0 ? void 0 : opts.optimize;
    const compilerOptionsOverwrite = (_a = opts === null || opts === void 0 ? void 0 : opts.nodeElmCompilerOptions) !== null && _a !== void 0 ? _a : {};
    return {
        name: 'vite-plugin-elm',
        enforce: 'pre',
        handleHotUpdate({ file, server, modules }) {
            const { valid } = parseImportId(file);
            if (!valid)
                return;
            const modulesToCompile = [];
            compilableFiles.forEach((dependencies, compilableFile) => {
                if (dependencies.has((0, path_1.normalize)(file))) {
                    const module = server.moduleGraph.getModuleById(compilableFile);
                    if (module)
                        modulesToCompile.push(module);
                }
            });
            if (modulesToCompile.length > 0) {
                server.ws.send({
                    type: 'custom',
                    event: 'hot-update-dependents',
                    data: modulesToCompile.map(({ url }) => url),
                });
                return modulesToCompile;
            }
            else {
                return modules;
            }
        },
        async load(id) {
            const { valid, pathname, withParams } = parseImportId(id);
            if (!valid)
                return;
            const accompanies = await (() => {
                if (withParams.length > 0) {
                    const importTree = this.getModuleIds();
                    let importer = '';
                    for (const moduleId of importTree) {
                        if (moduleId === id)
                            break;
                        importer = moduleId;
                    }
                    const resolveAcoompany = async (accompany) => { var _a, _b; return (_b = (_a = (await this.resolve(accompany, importer))) === null || _a === void 0 ? void 0 : _a.id) !== null && _b !== void 0 ? _b : ''; };
                    return Promise.all(withParams.map(resolveAcoompany));
                }
                else {
                    return Promise.resolve([]);
                }
            })();
            const targets = [pathname, ...accompanies].filter((target) => target !== '');
            compilableFiles.delete(id);
            const dependencies = (await Promise.all(targets.map((target) => node_elm_compiler_1.default.findAllDependencies(target)))).flat();
            compilableFiles.set(id, new Set([...accompanies, ...dependencies]));
            const releaseLock = await (0, mutex_1.acquireLock)();
            try {
                const isBuild = process.env.NODE_ENV === 'production';
                let compiled = await node_elm_compiler_1.default.compileToString(targets, {
                    output: '.js',
                    optimize: typeof optimize === 'boolean' ? optimize : !debug && isBuild,
                    verbose: isBuild,
                    debug: debug !== null && debug !== void 0 ? debug : !isBuild,
                    cwd: await findClosestElmJson(pathname),
                    ...compilerOptionsOverwrite,
                });
                // Post process
                compiled = compiled
                    .split('var bodyNode = _VirtualDom_doc.body')
                    .join('var bodyNode = _VirtualDom_doc.getElementById("elm_root") || _VirtualDom_doc.body')
                const esm = (0, assetsInjector_1.injectAssets)((0, elm_esm_1.toESModule)(compiled));
                // Apparently `addWatchFile` may not exist: https://github.com/hmsk/vite-plugin-elm/pull/36
                if (this.addWatchFile) {
                    dependencies.forEach(this.addWatchFile.bind(this));
                }
                return {
                    code: isBuild ? esm : trimDebugMessage((0, hmrInjector_1.injectHMR)(esm, dependencies.map(viteProjectPath))),
                    map: null,
                };
            }
            catch (e) {
                if (e instanceof Error && e.message.includes('-- NO MAIN')) {
                    const message = `${viteProjectPath(pathname)}: NO MAIN .elm file is requested to transform by vite. Probably, this file is just a depending module`;
                    throw message;
                }
                else {
                    throw e;
                }
            }
            finally {
                releaseLock();
            }
        },
    };
};
exports.plugin = plugin;
exports.default = exports.plugin;
//# sourceMappingURL=index.js.map