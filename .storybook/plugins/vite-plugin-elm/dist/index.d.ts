import type { Plugin } from 'vite';
type NodeElmCompilerOptions = {
    cwd?: string;
    docs?: string;
    debug?: boolean;
    optimize?: boolean;
    processOpts?: Record<string, string>;
    report?: string;
    pathToElm?: string;
    verbose?: boolean;
};
export declare const plugin: (opts?: {
    debug?: boolean;
    optimize?: boolean;
    nodeElmCompilerOptions: NodeElmCompilerOptions;
}) => Plugin;
export default plugin;
