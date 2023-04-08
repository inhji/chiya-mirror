import React, {useState, useEffect, useMemo} from 'react'
import {
  KBarProvider,
  KBarPortal,
  KBarPositioner,
  KBarAnimator,
  KBarSearch,
  KBarResults,
  useMatches,
  useRegisterActions,
  useKBar,
  createAction
} from "kbar";
import classNames from 'classnames';

const searchStyle = {
  padding: "12px 16px",
  fontSize: "16px",
  width: "100%",
  boxSizing: "border-box",
  outline: "none"
};

const animatorStyle = {
  maxWidth: "600px",
  width: "100%",
  borderRadius: "8px",
  overflow: "hidden"
};

const groupNameStyle = {
  padding: "8px 16px",
  fontSize: "10px",
  textTransform: "uppercase",
  opacity: 0.75,
};


function RenderResults() {
  const { results, rootActionId } = useMatches();

  return (
    <KBarResults
      items={results}
      onRender={({ item, active }) =>
        typeof item === "string" ? (
          <div style={groupNameStyle} class="dark:text-white">{item}</div>
        ) : (
          <ResultItem
            action={item}
            active={active}
            currentRootActionId={rootActionId}
          />
        )
      }
    />
  );
}

const ResultItem = React.forwardRef(
  (
    {
      action,
      active,
      currentRootActionId,
    },
    ref
  ) => {
    const ancestors = React.useMemo(() => {
      if (!currentRootActionId) return action.ancestors;
      const index = action.ancestors.findIndex(
        (ancestor) => ancestor.id === currentRootActionId
      );
      // +1 removes the currentRootAction; e.g.
      // if we are on the "Set theme" parent action,
      // the UI should not display "Set theme… > Dark"
      // but rather just "Dark"
      return action.ancestors.slice(index + 1);
    }, [action.ancestors, currentRootActionId]);

    return (
      <div
        ref={ref}
        className={classNames(
          "flex justify-between items-center cursor-pointer px-4 py-3 dark:text-white",
          { 
            "bg-gray-300 dark:bg-gray-600": active,
            "border-l-2 border-gray-300": active
          })}
      >
        <div className="flex gap-3 items-center text-sm dark:text-white">
          {action.icon && action.icon}
          <div className="flex flex-col">
            <div>
              {ancestors.length > 0 &&
                ancestors.map((ancestor) => (
                  <React.Fragment key={ancestor.id}>
                    <span
                      style={{
                        opacity: 0.5,
                        marginRight: 8,
                      }}
                    >
                      {ancestor.name}
                    </span>
                    <span
                      style={{
                        marginRight: 8,
                      }}
                    >
                      &rsaquo;
                    </span>
                  </React.Fragment>
                ))}
              <span>{action.name}</span>
            </div>
            {action.subtitle && (
              <span style={{ fontSize: 12 }}>{action.subtitle}</span>
            )}
          </div>
        </div>
        {action.shortcut?.length ? (
          <div
            aria-hidden
            style={{ display: "grid", gridAutoFlow: "column", gap: "4px" }}
          >
            {action.shortcut.map((sc) => (
              <kbd
                key={sc}
                style={{
                  padding: "4px 6px",
                  background: "rgba(0 0 0 / .1)",
                  borderRadius: "4px",
                  fontSize: 14,
                }}
              >
                {sc}
              </kbd>
            ))}
          </div>
        ) : null}
      </div>
    );
  }
);

const staticActions = [
  {
    id: "user",
    name: "User",
    shortcut: ["u"],
    keywords: "profile",
    perform: () => (window.location.pathname = "user"),
  },
  {
    id: "user.edit",
    name: "Edit User",
    shortcut: ["u e"],
    keywords: "profile edit settings",
    perform: () => (window.location.pathname = "user/settings"),
  },
  {
    id: "admin",
    name: "Admin",
    shortcut: ["a"],
    keywords: "home",
    perform: () => (window.location.pathname = "admin"),
  },
  {
    id: "notes",
    name: "Notes",
    shortcut: ["n"],
    keywords: "posts",
    perform: () => (window.location.pathname = "admin/notes"),
  },
  {
    id: "notes.new",
    name: "New Note",
    shortcut: ["n n"],
    keywords: "create new",
    perform: () => (window.location.pathname = "admin/notes/new"),
  },
  {
    id: "channels",
    name: "Channels",
    shortcut: ["c"],
    keywords: "channels",
    perform: () => (window.location.pathname = "admin/channels"),
  },
  {
    id: "channels.new",
    name: "New Channel",
    shortcut: ["n c"],
    keywords: "create new",
    perform: () => (window.location.pathname = "admin/channels/new"),
  },
  {
    id: "identities",
    name: "Identities",
    shortcut: ["i"],
    keywords: "identities",
    perform: () => (window.location.pathname = "admin/identities"),
  },
  {
    id: "identities.new",
    name: "New Identity",
    shortcut: ["n i"],
    keywords: "create new",
    perform: () => (window.location.pathname = "admin/identities/new"),
  },
  {
    id: "settings",
    name: "Settings",
    shortcut: ["s"],
    keywords: "settings",
    perform: () => (window.location.pathname = "admin/settings"),
  },
  {
    id: "settings.edit",
    name: "Edit Settings",
    shortcut: ["s e"],
    keywords: "settings edit",
    perform: () => (window.location.pathname = "admin/settings/edit"),
  }
].map(function(a) { 
  return {...a, section: "Pages"}
})

function DynamicResultsProvider() {
  const [actions, setActions] = useState([])
  const [notes, setNotes] = useState([])
  const [rerender, setRerender] = useState(true)

  useEffect(() => {
    fetch("/api/admin/notes")
      .then(resp => resp.json())
      .then(json => setNotes(json.notes))
  }, [rerender])


  const noteActions = useMemo(() => notes.map(note => createAction({
    id: note.slug,
    name: note.name,
    subtitle: note.channels.map(c => c.name).join(", "),
    section: "Notes",
    keywords: note.channels.map(c => c.name),
    perform: () => (window.location.pathname = `/admin/notes/${note.id}`),
  })), [notes])

  useRegisterActions([...staticActions, ...noteActions], [noteActions])
}

export default function KBar() {
  return (
    <KBarProvider actions={staticActions}>
      <DynamicResultsProvider />
      <KBarPortal>
        <KBarPositioner>
          <KBarAnimator style={animatorStyle} className="bg-gray-50 border border-gray-100 shadow-sm dark:bg-gray-900 dark:border-gray-800">
            <KBarSearch style={searchStyle} className="bg-gray-50 dark:bg-gray-900 border-b border-gray-100 text-gray-900 dark:text-gray-100" />
            <RenderResults />
          </KBarAnimator>
        </KBarPositioner>
      </KBarPortal>
    </KBarProvider>
  )
}