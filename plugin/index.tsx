import definePlugin from "@utils/types";

export default definePlugin({
    name: "Ginga",
    description: "Unblock camera and screen share (neutralizes the BR regional video-guard).",
    authors: [{ name: "marcosdanielr", id: 0n }],

    patches: [
        {
            find: '"2026-08-video-guard"',
            replacement: {
                match: /videoEnabled:!1/g,
                replace: "videoEnabled:!0",
            },
        },
    ],
});
